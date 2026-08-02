import 'package:flutter/material.dart';
import 'package:dart_pdf_editor/dart_pdf_editor.dart';

class PdfViewerArea extends StatefulWidget {
  final PdfEditingController pdfController;

  const PdfViewerArea({super.key, required this.pdfController});

  @override
  State<PdfViewerArea> createState() => _PdfViewerAreaState();
}

class _PdfViewerAreaState extends State<PdfViewerArea> {
  late PdfViewerController _viewerController;
  late TextEditingController _zoomTextController;

  @override
  void initState() {
    super.initState();
    _viewerController = PdfViewerController();
    _zoomTextController = TextEditingController();

    _viewerController.viewportChanges.addListener(
      _updateZoomTextFromController,
    );
  }

  void _updateZoomTextFromController() {
    final viewport = _viewerController.captureViewport();
    if (viewport != null) {
      final zoomPercentage = (_viewerController.zoom * 100).round();
      final newText = '$zoomPercentage%';

      if (_zoomTextController.text != newText) {
        _zoomTextController.text = newText;
      }
    }
  }

  void _zoomIn() {
    final newZoom = _viewerController.zoom * 1.25;
    if (newZoom <= 0.9) _viewerController.setZoom(newZoom);
  }

  void _zoomOut() {
    final newZoom = _viewerController.zoom / 1.25;
    if (newZoom >= 0.5) _viewerController.setZoom(newZoom);
  }

  void _setZoomFromText(String value) {
    final cleanedValue = value.replaceAll('%', '').trim();
    final parsed = double.tryParse(cleanedValue);

    if (parsed != null && parsed > 0) {
      final requestedZoom = parsed / 100.0;
      final safeZoom = requestedZoom.clamp(0.5, 0.9);
      _viewerController.setZoom(safeZoom);

      if (requestedZoom != safeZoom) {
        _zoomTextController.text = '${(safeZoom * 100).round()}%';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: PdfEditorView(
                      controller: widget.pdfController,
                      viewerController: _viewerController,
                      features: const PdfEditorFeatures(search: false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade800.withValues(alpha: 0.8)
                    : Colors.grey.shade500.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                    onPressed: _zoomOut,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _zoomTextController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onSubmitted: _setZoomFromText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                    color: Colors.white,
                    onPressed: _zoomIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _viewerController.viewportChanges.removeListener(
      _updateZoomTextFromController,
    );
    _viewerController.dispose();
    _zoomTextController.dispose();
    super.dispose();
  }
}
