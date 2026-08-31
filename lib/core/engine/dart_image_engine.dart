import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import 'image_engine.dart';

/// Pure-Dart image segmentation engine.
///
/// Implements the full pipeline:
///   1. Background colour detection (robust border + corner sampling, mode-based)
///   2. BFS flood-fill background removal → RGBA image with alpha=0 on background
///   3. Edge feathering (soft alpha at boundaries)
///   4. Optional erosion to separate touching sprites
///   5. Connected-Component Labelling (two-pass Union-Find)
///   6. Bounding-box extraction + noise filtering
///   7. Failure detection: if background removal yields >90% foreground coverage,
///      or CCL returns a single blob covering the full canvas, a SegmentationResult
///      with detectionFailure=true and no elements is returned instead of a false
///      positive 1-element result.
///   8. Element crop export as PNG with alpha
///
/// NEVER imports opencv_dart, dartcv4, or any package that vendors OpenCV source.
class DartImageEngine implements ImageEngine {
  const DartImageEngine();

  // ──────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────

  @override
  Future<SegmentationResult> processSheet({
    required Uint8List imageBytes,
    required ProcessingOptions options,
    ProgressCallback? onProgress,
  }) async {
    // Run heavy work in a separate isolate via Flutter's compute().
    // We pass everything as plain Maps/Uint8Lists (isolate-safe types).
    final params = {
      'imageBytes': imageBytes,
      ...options.toMap(),
    };

    onProgress?.call('Removing background…', 0.05);
    final result = await _runInIsolate(params);
    onProgress?.call('Done', 1.0);
    return result;
  }

  @override
  Future<Uint8List> renderElement({
    required DetectedElement element,
    required ExportOptions exportOptions,
  }) async {
    final bgColor = element.backgroundColorOverride ??
        exportOptions.globalBackgroundColor;
    if (bgColor == null) {
      return element.cropBytes; // already transparent — return as-is
    }
    return _applyBackground(element.cropBytes, bgColor.toARGB32());
  }

  @override
  Future<List<String>> exportElements({
    required SegmentationResult result,
    required ExportOptions exportOptions,
    ProgressCallback? onProgress,
  }) async {
    final elements = exportOptions.exportSelectedOnly
        ? exportOptions.selectedIndices
            .where((i) => i < result.elements.length)
            .map((i) => result.elements[i])
            .toList()
        : result.elements;

    final dir = Directory(exportOptions.outputFolder);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final paths = <String>[];
    for (var i = 0; i < elements.length; i++) {
      final el = elements[i];
      final bytes = await renderElement(
        element: el,
        exportOptions: exportOptions,
      );

      final filename = _buildFilename(
        el,
        exportOptions.namingScheme,
        result.originalWidth,
        result.originalHeight,
      );
      final filePath = p.join(exportOptions.outputFolder, filename);
      await File(filePath).writeAsBytes(bytes);
      paths.add(filePath);
      onProgress?.call('Exporting…', (i + 1) / elements.length);
    }
    return paths;
  }

  // ──────────────────────────────────────────────────────────────
  // Isolate entry point  (static — safe to send through compute)
  // ──────────────────────────────────────────────────────────────

  /// Called inside the isolate. Performs the entire segmentation pipeline.
  static Future<SegmentationResult> _runInIsolate(
      Map<String, dynamic> params) async {
    final imageBytes = params['imageBytes'] as Uint8List;
    final opts = ProcessingOptions.fromMap(params.cast<String, dynamic>());
    final log = <String>[];

    // 1. Decode
    final source = img.decodeImage(imageBytes);
    if (source == null) throw Exception('Failed to decode image.');

    log.add('Image: ${source.width}×${source.height}px  '
        'hasAlpha=${source.hasAlpha}  '
        'format=${source.format}');
    log.add('Options: tolerance=${opts.backgroundTolerance}  '
        'erosion=${opts.erosionAmount}  '
        'feather=${opts.featheringRadius}  '
        'minSize=${opts.minElementSize}');

    final origBytes = Uint8List.fromList(imageBytes); // keep for fallback

    // 2. Remove background → produces RGBA image with alpha=0 on background
    final _RemoveResult removeResult = _removeBackground(source, opts);
    final masked = removeResult.image;
    log.add('Background removal: trustedExistingAlpha=${removeResult.trustedExistingAlpha}');

    // 3. Post-removal sanity check: if >90% of canvas is still foreground,
    //    background removal was ineffective — declare a detection failure.
    //    ONLY apply this guard when a flood-fill was performed. If we trusted
    //    the existing alpha channel, high foreground coverage is expected
    //    (dense sprite sheets legitimately fill most of the canvas).
    final fgRatio = _foregroundCoverageRatio(masked, source.width, source.height);
    log.add('Foreground coverage after removal: ${(fgRatio * 100).toStringAsFixed(1)}%');

    if (!removeResult.trustedExistingAlpha && fgRatio > 0.90) {
      final msg = 'Detection failure: foreground coverage '
          '${(fgRatio * 100).toStringAsFixed(1)}% >90% after flood-fill. '
          'No meaningful background was removed.';
      log.add(msg);
      debugPrint('[DartImageEngine] $msg');
      return SegmentationResult(
        processedSheetBytes: origBytes,
        originalWidth: source.width,
        originalHeight: source.height,
        elements: const [],
        detectionFailure: true,
        diagnosticLog: log,
      );
    }

    // 4. Apply feathering on edges
    final feathered = opts.featheringRadius > 0
        ? _featherEdges(masked, opts.featheringRadius)
        : masked;

    // 5. Run CCL on the alpha mask (optionally eroded)
    final components = _runCCL(feathered, opts);
    log.add('CCL: ${components.length} component(s) found '
        '(after minSize=${opts.minElementSize} filter)');

    // 6. Single-full-canvas-blob guard: if CCL yields exactly 1 component
    //    covering ≥90% of the canvas, treat it as a detection failure.
    if (_isSingleBlobFailure(components, source.width, source.height)) {
      final msg = 'Detection failure: single blob covering ≥90% of canvas '
          '(${components.first.width}×${components.first.height} '
          'on ${source.width}×${source.height} canvas).';
      log.add(msg);
      debugPrint('[DartImageEngine] $msg');
      return SegmentationResult(
        processedSheetBytes: origBytes,
        originalWidth: source.width,
        originalHeight: source.height,
        elements: const [],
        detectionFailure: true,
        diagnosticLog: log,
      );
    }

    // 7. Crop each component
    final elements = _cropElements(feathered, components, opts);
    log.add('Elements extracted: ${elements.length}');

    // 8. Encode processed sheet
    final processedBytes =
        Uint8List.fromList(img.encodePng(feathered));
    log.add('Done. Result: ${elements.length} element(s) detected.');

    return SegmentationResult(
      processedSheetBytes: processedBytes,
      originalWidth: source.width,
      originalHeight: source.height,
      elements: elements,
      detectionFailure: false,
      diagnosticLog: log,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Step 1 — Background removal
  // ──────────────────────────────────────────────────────────────

  static _RemoveResult _removeBackground(
      img.Image src, ProcessingOptions opts) {
    final w = src.width;
    final h = src.height;

    // Ensure the working image has an alpha channel. RGB images (hasAlpha=false)
    // must be promoted to RGBA before we can set pixels transparent via BFS.
    // Image.convert(numChannels: 4) adds an alpha channel initialized to 255.
    final rgba = src.numChannels < 4
        ? src.convert(numChannels: 4)
        : src.clone();

    // Detect if image already has *genuine* widespread transparency.
    // We require BOTH:
    //   a) >50% of sampled pixels are transparent (not just 25%)
    //   b) Border pixels specifically include transparent pixels
    // This prevents near-opaque sheets with minor JPEG fringing from
    // short-circuiting the flood-fill.
    if (_hasGenuineTransparency(rgba)) {
      // The alpha channel is already meaningful — trust it as the mask.
      // However, also check whether there is a FLAT-COLOR backdrop still
      // present in the opaque regions (some sheets have partial transparency
      // + a solid-color background). We do a supplementary border flood-fill.
      return _RemoveResult(
        image: _supplementaryBorderFloodFill(rgba, opts),
        trustedExistingAlpha: true,
      );
    }

    // Sample background colour from ALL 4 borders + 4 corners using
    // mode-based detection to handle JPEG/compression noise (±10 tolerance).
    final bgColor = _detectBackgroundColor(rgba);

    // BFS flood-fill from all border pixels
    final visited = List.filled(w * h, false);
    final queue = Queue<int>();

    void enqueue(int x, int y) {
      if (x < 0 || y < 0 || x >= w || y >= h) return;
      final idx = y * w + x;
      if (visited[idx]) return;
      final px = rgba.getPixel(x, y);
      if (_colorDistance(px, bgColor) <= opts.backgroundTolerance) {
        visited[idx] = true;
        queue.add(idx);
      }
    }

    // Seed from all 4 borders
    for (var x = 0; x < w; x++) {
      enqueue(x, 0);
      enqueue(x, h - 1);
    }
    for (var y = 0; y < h; y++) {
      enqueue(0, y);
      enqueue(w - 1, y);
    }

    // BFS
    const dx = [1, -1, 0, 0];
    const dy = [0, 0, 1, -1];
    while (queue.isNotEmpty) {
      final idx = queue.removeFirst();
      final x = idx % w;
      final y = idx ~/ w;
      for (var d = 0; d < 4; d++) {
        enqueue(x + dx[d], y + dy[d]);
      }
    }

    // Apply: set visited pixels to transparent
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (visited[y * w + x]) {
          rgba.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }

    return _RemoveResult(image: rgba);
  }

  /// Returns true if the image has *genuine* widespread transparency:
  ///   - >50% of sampled interior pixels are fully transparent, AND
  ///   - At least one border pixel is transparent.
  ///
  /// Requiring both conditions prevents near-opaque sheets with minor
  /// JPEG fringing (which may have scattered low-alpha pixels) from
  /// being mistakenly treated as already-transparent sheets.
  static bool _hasGenuineTransparency(img.Image src) {
    if (!src.hasAlpha) return false;
    final w = src.width;
    final h = src.height;

    // --- Condition A: interior sample majority ---
    int transparentCount = 0;
    const checkCount = 300;
    final step = math.max(1, (w * h) ~/ checkCount);
    for (var i = 0; i < w * h; i += step) {
      final px = src.getPixel(i % w, i ~/ w);
      if (px.a < 10) transparentCount++;
    }
    final majorityTransparent = transparentCount > checkCount ~/ 2; // >50%

    if (!majorityTransparent) return false;

    // --- Condition B: at least one border pixel is transparent ---
    // Sample every 8th pixel on each border (fast).
    bool borderTransparent = false;
    for (var x = 0; x < w && !borderTransparent; x += 8) {
      if (src.getPixel(x, 0).a < 10) borderTransparent = true;
      if (src.getPixel(x, h - 1).a < 10) borderTransparent = true;
    }
    for (var y = 0; y < h && !borderTransparent; y += 8) {
      if (src.getPixel(0, y).a < 10) borderTransparent = true;
      if (src.getPixel(w - 1, y).a < 10) borderTransparent = true;
    }

    return borderTransparent;
  }

  /// Supplementary flood-fill for sheets that already have alpha but may also
  /// have a solid-color background strip (section labels, banners, etc.).
  /// Only removes pixels that are fully opaque AND match the border color.
  static img.Image _supplementaryBorderFloodFill(
      img.Image src, ProcessingOptions opts) {
    final w = src.width;
    final h = src.height;
    final result = src.clone();

    // Only run if there are clearly opaque border regions
    // (i.e., sheet has mixed transparency — partial transparent + opaque BG).
    final bgColor = _detectBackgroundColor(src);

    // Only flood-fill pixels that are fully opaque AND close to the border color.
    // Use a tighter tolerance (half of user setting) to avoid eating sprite content.
    final tol = (opts.backgroundTolerance ~/ 2).clamp(5, 30);

    final visited = List.filled(w * h, false);
    final queue = Queue<int>();

    void enqueue(int x, int y) {
      if (x < 0 || y < 0 || x >= w || y >= h) return;
      final idx = y * w + x;
      if (visited[idx]) return;
      final px = src.getPixel(x, y);
      // Only eat pixels that are OPAQUE and match the background color
      if (px.a > 200 && _colorDistance(px, bgColor) <= tol) {
        visited[idx] = true;
        queue.add(idx);
      }
    }

    for (var x = 0; x < w; x++) {
      enqueue(x, 0);
      enqueue(x, h - 1);
    }
    for (var y = 0; y < h; y++) {
      enqueue(0, y);
      enqueue(w - 1, y);
    }

    const dx = [1, -1, 0, 0];
    const dy = [0, 0, 1, -1];
    while (queue.isNotEmpty) {
      final idx = queue.removeFirst();
      final x = idx % w;
      final y = idx ~/ w;
      result.setPixelRgba(x, y, 0, 0, 0, 0);
      for (var d = 0; d < 4; d++) {
        enqueue(x + dx[d], y + dy[d]);
      }
    }

    return result;
  }

  /// Detects the background colour using mode-based sampling of all 4 borders
  /// plus all 4 corners. Uses ±10 per-channel tolerance buckets to handle
  /// JPEG/compression noise robustly.
  static _RGB _detectBackgroundColor(img.Image src) {
    final w = src.width;
    final h = src.height;

    final samples = <_RGB>[];

    // Sample every 4th pixel on all 4 borders (fast, covers full border)
    for (var x = 0; x < w; x += 4) {
      _addBorderSample(src, x, 0, samples);
      _addBorderSample(src, x, h - 1, samples);
    }
    for (var y = 0; y < h; y += 4) {
      _addBorderSample(src, 0, y, samples);
      _addBorderSample(src, w - 1, y, samples);
    }

    // Also sample 8×8 corner grids for extra weight on corners
    const cornerSize = 8;
    for (var sy = 0; sy < math.min(cornerSize, h); sy++) {
      for (var sx = 0; sx < math.min(cornerSize, w); sx++) {
        _addBorderSample(src, sx, sy, samples);
        _addBorderSample(src, w - 1 - sx, sy, samples);
        _addBorderSample(src, sx, h - 1 - sy, samples);
        _addBorderSample(src, w - 1 - sx, h - 1 - sy, samples);
      }
    }

    if (samples.isEmpty) return _RGB(255, 255, 255);

    return _modeColor(samples);
  }

  /// Adds a border pixel to the sample list, skipping transparent pixels.
  static void _addBorderSample(
      img.Image src, int x, int y, List<_RGB> samples) {
    if (x < 0 || y < 0 || x >= src.width || y >= src.height) return;
    final px = src.getPixel(x, y);
    if (px.a < 128) return; // skip transparent pixels
    samples.add(_RGB(px.r.toInt(), px.g.toInt(), px.b.toInt()));
  }

  /// Returns the mode color from a list of samples using ±10 per-channel
  /// tolerance buckets. More robust than median for backgrounds with
  /// JPEG compression noise.
  static _RGB _modeColor(List<_RGB> samples) {
    // Bucket each channel into bins of width 10
    const bucketSize = 10;
    final rBuckets = <int, int>{};
    final gBuckets = <int, int>{};
    final bBuckets = <int, int>{};

    for (final s in samples) {
      final rb = (s.r ~/ bucketSize) * bucketSize;
      final gb = (s.g ~/ bucketSize) * bucketSize;
      final bb = (s.b ~/ bucketSize) * bucketSize;
      rBuckets[rb] = (rBuckets[rb] ?? 0) + 1;
      gBuckets[gb] = (gBuckets[gb] ?? 0) + 1;
      bBuckets[bb] = (bBuckets[bb] ?? 0) + 1;
    }

    int modeR = 255, modeG = 255, modeB = 255;
    int maxR = 0, maxG = 0, maxB = 0;
    for (final e in rBuckets.entries) {
      if (e.value > maxR) { maxR = e.value; modeR = e.key + bucketSize ~/ 2; }
    }
    for (final e in gBuckets.entries) {
      if (e.value > maxG) { maxG = e.value; modeG = e.key + bucketSize ~/ 2; }
    }
    for (final e in bBuckets.entries) {
      if (e.value > maxB) { maxB = e.value; modeB = e.key + bucketSize ~/ 2; }
    }

    return _RGB(modeR.clamp(0, 255), modeG.clamp(0, 255), modeB.clamp(0, 255));
  }

  static int _colorDistance(img.Pixel px, _RGB ref) {
    final dr = px.r.toInt() - ref.r;
    final dg = px.g.toInt() - ref.g;
    final db = px.b.toInt() - ref.b;
    return (dr.abs() + dg.abs() + db.abs()) ~/ 3;
  }

  // ──────────────────────────────────────────────────────────────
  // Post-removal sanity checks
  // ──────────────────────────────────────────────────────────────

  /// Returns the fraction (0.0–1.0) of canvas pixels that are foreground
  /// (alpha > 10) after background removal. Sampled every 4th pixel for speed.
  static double _foregroundCoverageRatio(img.Image masked, int w, int h) {
    final total = w * h;
    if (total == 0) return 0;
    int foreground = 0;
    int checked = 0;
    for (var i = 0; i < total; i += 4) {
      final px = masked.getPixel(i % w, i ~/ w);
      if (px.a > 10) foreground++;
      checked++;
    }
    return checked == 0 ? 0 : foreground / checked;
  }

  /// Returns true if CCL produced exactly 1 component whose bounding box
  /// covers ≥90% of the canvas area — i.e., a single giant blob that is
  /// almost certainly a detection failure rather than a real single element.
  static bool _isSingleBlobFailure(
      List<_ComponentInfo> components, int w, int h) {
    if (components.length != 1) return false;
    final c = components.first;
    final blobArea = c.width * c.height;
    final canvasArea = w * h;
    return blobArea >= canvasArea * 0.90;
  }

  // ──────────────────────────────────────────────────────────────
  // Step 2 — Edge feathering
  // ──────────────────────────────────────────────────────────────

  static img.Image _featherEdges(img.Image src, int radius) {
    final w = src.width;
    final h = src.height;
    final result = src.clone();

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final px = src.getPixel(x, y);
        if (px.a < 5) continue; // already transparent

        // Check if any neighbour within radius is transparent
        double minDist = double.infinity;
        for (var dy = -radius; dy <= radius; dy++) {
          for (var dx = -radius; dx <= radius; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= w || ny >= h) {
              minDist = 0;
              break;
            }
            final np = src.getPixel(nx, ny);
            if (np.a < 5) {
              final dist = math.sqrt(dx * dx + dy * dy);
              if (dist < minDist) minDist = dist;
            }
          }
          if (minDist == 0) break;
        }

        if (minDist < radius) {
          // Feather: reduce alpha proportionally to distance from edge
          final ratio = minDist / radius;
          final newAlpha = (px.a.toInt() * ratio).round().clamp(0, 255);
          result.setPixelRgba(x, y, px.r.toInt(), px.g.toInt(),
              px.b.toInt(), newAlpha);
        }
      }
    }
    return result;
  }

  // ──────────────────────────────────────────────────────────────
  // Step 3 — Connected-Component Labelling (two-pass Union-Find)
  // ──────────────────────────────────────────────────────────────

  static List<_ComponentInfo> _runCCL(
      img.Image src, ProcessingOptions opts) {
    final w = src.width;
    final h = src.height;

    // Optional erosion step to separate touching sprites
    final workMask = opts.erosionAmount > 0
        ? _erodeAlpha(src, opts.erosionAmount)
        : _buildAlphaMask(src);

    // First pass: provisional labelling with Union-Find
    final labels = List.filled(w * h, 0);
    final uf = _UnionFind();
    int nextLabel = 1;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (!workMask[y * w + x]) continue;

        final left = x > 0 && workMask[y * w + x - 1] ? labels[y * w + x - 1] : 0;
        final top = y > 0 && workMask[(y - 1) * w + x] ? labels[(y - 1) * w + x] : 0;

        if (left == 0 && top == 0) {
          labels[y * w + x] = nextLabel;
          uf.makeSet(nextLabel);
          nextLabel++;
        } else if (left != 0 && top == 0) {
          labels[y * w + x] = left;
        } else if (left == 0 && top != 0) {
          labels[y * w + x] = top;
        } else {
          // Both labeled — union them
          labels[y * w + x] = left;
          uf.union(left, top);
        }
      }
    }

    // Second pass: resolve labels, collect bounding boxes on original mask
    final boxes = <int, _BBox>{};
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final lbl = labels[y * w + x];
        if (lbl == 0) continue;
        // Check the ORIGINAL image alpha (not eroded), so we get full extent
        final origPx = src.getPixel(x, y);
        if (origPx.a < 10) continue;

        final canonical = uf.find(lbl);
        final bbox = boxes.putIfAbsent(canonical, _BBox.new);
        bbox.include(x, y);
      }
    }

    // Convert to ComponentInfo, applying padding + min-size filter
    final result = <_ComponentInfo>[];
    for (final entry in boxes.entries) {
      final bb = entry.value;
      final area = bb.width * bb.height;
      if (area < opts.minElementSize) continue;

      final padded = _BBox.fromLTWH(
        math.max(0, bb.xMin - opts.elementPadding),
        math.max(0, bb.yMin - opts.elementPadding),
        math.min(w, bb.xMax + 1 + opts.elementPadding) -
            math.max(0, bb.xMin - opts.elementPadding),
        math.min(h, bb.yMax + 1 + opts.elementPadding) -
            math.max(0, bb.yMin - opts.elementPadding),
      );

      result.add(_ComponentInfo(
        label: entry.key,
        x: padded.xMin,
        y: padded.yMin,
        width: padded.width,
        height: padded.height,
      ));
    }

    // Sort top-to-bottom, left-to-right
    result.sort((a, b) {
      const rowThreshold = 20;
      final rowDiff = (a.y - b.y);
      if (rowDiff.abs() > rowThreshold) return rowDiff;
      return a.x - b.x;
    });

    return result;
  }

  static List<bool> _buildAlphaMask(img.Image src) {
    final w = src.width;
    final h = src.height;
    return List.generate(w * h, (i) {
      final px = src.getPixel(i % w, i ~/ w);
      return px.a > 10;
    });
  }

  static List<bool> _erodeAlpha(img.Image src, int amount) {
    final w = src.width;
    final h = src.height;
    var mask = _buildAlphaMask(src);

    for (var iter = 0; iter < amount; iter++) {
      final next = List.filled(w * h, false);
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          if (!mask[y * w + x]) continue;
          // Erode: only keep if all 4 neighbours are also foreground
          final ok = (x > 0 && mask[y * w + x - 1]) &&
              (x < w - 1 && mask[y * w + x + 1]) &&
              (y > 0 && mask[(y - 1) * w + x]) &&
              (y < h - 1 && mask[(y + 1) * w + x]);
          next[y * w + x] = ok;
        }
      }
      mask = next;
    }
    return mask;
  }

  // ──────────────────────────────────────────────────────────────
  // Step 4 — Crop elements from processed sheet
  // ──────────────────────────────────────────────────────────────

  static List<DetectedElement> _cropElements(
    img.Image src,
    List<_ComponentInfo> components,
    ProcessingOptions opts,
  ) {
    final elements = <DetectedElement>[];
    for (var i = 0; i < components.length; i++) {
      final c = components[i];
      final crop = img.copyCrop(
        src,
        x: c.x,
        y: c.y,
        width: c.width,
        height: c.height,
      );
      final cropBytes = Uint8List.fromList(img.encodePng(crop));
      final id = 'element_${(i + 1).toString().padLeft(3, '0')}';
      elements.add(DetectedElement(
        id: id,
        index: i,
        x: c.x,
        y: c.y,
        width: c.width,
        height: c.height,
        cropBytes: cropBytes,
      ));
    }
    return elements;
  }

  // ──────────────────────────────────────────────────────────────
  // Background application for export/preview
  // ──────────────────────────────────────────────────────────────

  static Future<Uint8List> _applyBackground(
      Uint8List cropBytes, int colorValue) async {
    img.Image? crop;
    try {
      crop = img.decodeImage(cropBytes);
    } catch (e, st) {
      debugPrint('[DartImageEngine] _applyBackground: decode error: $e\n$st');
    }
    if (crop == null) return cropBytes;

    final a = (colorValue >> 24) & 0xFF;
    final r = (colorValue >> 16) & 0xFF;
    final g = (colorValue >> 8) & 0xFF;
    final b = colorValue & 0xFF;

    final result = img.Image(width: crop.width, height: crop.height);
    for (var y = 0; y < crop.height; y++) {
      for (var x = 0; x < crop.width; x++) {
        final src = crop.getPixel(x, y);
        if (src.a < 10) {
          result.setPixelRgba(x, y, r, g, b, a == 0 ? 255 : a);
        } else {
          result.setPixel(x, y, src);
        }
      }
    }
    return Uint8List.fromList(img.encodePng(result));
  }

  // ──────────────────────────────────────────────────────────────
  // Filename builder
  // ──────────────────────────────────────────────────────────────

  static String _buildFilename(
    DetectedElement el,
    NamingScheme scheme,
    int totalWidth,
    int totalHeight,
  ) {
    switch (scheme) {
      case NamingScheme.positional:
        return '${el.positionalName(totalWidth, totalHeight)}.png';
      case NamingScheme.custom:
        return '${el.customName ?? el.id}.png';
      case NamingScheme.sequential:
        return '${el.id}.png';
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Internal helpers
// ──────────────────────────────────────────────────────────────

/// Wraps the result of a background removal step.
class _RemoveResult {
  final img.Image image;
  /// True when the pipeline trusted the existing alpha channel instead of
  /// running a flood-fill. In this case the foreground-coverage guard must
  /// NOT be applied, because a dense legitimate sprite sheet can have >90%
  /// foreground coverage by design.
  final bool trustedExistingAlpha;
  const _RemoveResult({required this.image, this.trustedExistingAlpha = false});
}

class _RGB {
  final int r, g, b;
  const _RGB(this.r, this.g, this.b);
}

class _BBox {
  int xMin = 9999999, yMin = 9999999;
  int xMax = 0, yMax = 0;

  _BBox();

  int get width => xMax - xMin + 1;
  int get height => yMax - yMin + 1;

  void include(int x, int y) {
    if (x < xMin) xMin = x;
    if (y < yMin) yMin = y;
    if (x > xMax) xMax = x;
    if (y > yMax) yMax = y;
  }

  factory _BBox.fromLTWH(int x, int y, int w, int h) => _BBox()
    ..xMin = x
    ..yMin = y
    ..xMax = x + w - 1
    ..yMax = y + h - 1;
}

class _ComponentInfo {
  final int label;
  final int x, y, width, height;
  const _ComponentInfo({
    required this.label,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// Union-Find (Disjoint Set Union) for CCL label equivalence resolution.
class _UnionFind {
  final _parent = <int, int>{};
  final _rank = <int, int>{};

  void makeSet(int x) {
    _parent[x] = x;
    _rank[x] = 0;
  }

  int find(int x) {
    if (_parent[x] == null) makeSet(x);
    if (_parent[x] != x) _parent[x] = find(_parent[x]!);
    return _parent[x]!;
  }

  void union(int x, int y) {
    final rx = find(x);
    final ry = find(y);
    if (rx == ry) return;
    final rankX = _rank[rx] ?? 0;
    final rankY = _rank[ry] ?? 0;
    if (rankX < rankY) {
      _parent[rx] = ry;
    } else if (rankX > rankY) {
      _parent[ry] = rx;
    } else {
      _parent[ry] = rx;
      _rank[rx] = rankX + 1;
    }
  }
}
