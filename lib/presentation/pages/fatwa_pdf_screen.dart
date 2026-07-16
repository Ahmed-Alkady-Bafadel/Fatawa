import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fatawa/data/repositories/fatwa_repository.dart';
import 'package:fatawa/presentation/cubit/fatwa_loading_cubit.dart';
import 'package:flutter/material.dart';
import 'package:dart_pdf_editor/dart_pdf_editor.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/fatwa_model.dart';
import '../../../core/theme/app_colors.dart';

class FatwaPdfScreen extends StatefulWidget {
  final FatwaModel fatwa;

  const FatwaPdfScreen({super.key, required this.fatwa});

  @override
  State<FatwaPdfScreen> createState() => _FatwaPdfScreenState();
}

class _FatwaPdfScreenState extends State<FatwaPdfScreen> {
  // ─── متحكمات الـ PDF والعرض ───────────────────────────────────
  late PdfEditingController? _pdfController;
  late PdfViewerController _viewerController; // متحكم منفصل للتحكم بالعرض
  late TextEditingController _zoomTextController;
  final Completer<void> _viewportReady = Completer<void>();

  bool _isLoadingPdf = true;
  // ─── متحكمات الإدخال (النص والصوت) ───────────────────────────
  late TextEditingController _noteController;
  late RecorderController _recorderController;
  late PlayerController _playerController;

  bool _isRecordingMode = false;
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isPlaying = false;
  bool _isSaved = false;
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.fatwa.textAnswer ?? '',
    );

    _viewerController = PdfViewerController();
    _viewerController.viewportChanges.addListener(
      _updateZoomTextFromController,
    ); // تهيئة متحكم العرض
    _zoomTextController = TextEditingController();
    _initAudioControllers();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      if (widget.fatwa.localPdfPath != null) {
        final file = File(widget.fatwa.localPdfPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          if (bytes.isNotEmpty) {
            _pdfController = PdfEditingController(bytes);
          }
          // _totalPages = _pdfController!.document?.pageCount ?? 1;
          setState(() {
            _isLoadingPdf = false;
          });
          await _viewportReady.future;

          _updateZoomTextFromController();
        }
      }
      // إذا لم يوجد ملف PDF، نقوم بإنشاء مستند فارغ لتجنب الانهيار
      setState(() {
        _isLoadingPdf = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPdf = false;
      });
    }
  }

  void _updateZoomTextFromController() {
    if (!mounted) return;

    final viewport = _viewerController.captureViewport();
    if (viewport != null) {
      final zoomPercentage = (_viewerController.zoom * 100).round();
      final newText = '$zoomPercentage%';

      if (_zoomTextController.text != newText) {
        setState(() {
          _zoomTextController.text = newText;
          // _currentPage = _viewerController.currentPage + 1;
          // _totalPages = _viewerController.pageCount;
        });
      }
    }
  }

  void _zoomIn() {
    _viewerController.setZoom(_viewerController.zoom * 1.25);
  }

  void _zoomOut() {
    _viewerController.setZoom(_viewerController.zoom / 1.25);
  }

  void _setZoomFromText(String value) {
    final cleanedValue = value.replaceAll('%', '').trim();
    final parsed = double.tryParse(cleanedValue);

    if (parsed != null && parsed > 0) {
      _viewerController.setZoom(parsed / 100.0);
    }
  }

  void _initAudioControllers() {
    _recorderController = RecorderController();
    _playerController = PlayerController();

    _playerController.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _playerController.onCompletion.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorderController.checkPermission();
    if (!hasPermission) return;

    final dir = await getApplicationDocumentsDirectory();
    _audioFilePath =
        '${dir.path}/fatwa_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorderController.record(path: _audioFilePath);
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _recorderController.stop();
    if (path != null) {
      setState(() {
        _isRecording = false;
        _hasRecorded = true;
        _audioFilePath = path;
      });
      await _playerController.preparePlayer(path: path);
    }
  }

  void _deleteRecording() {
    setState(() {
      _hasRecorded = false;
      _audioFilePath = null;
    });
    _playerController.stopPlayer();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _playerController.pausePlayer();
    } else {
      await _playerController.startPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) =>
          FatwaLoadingCubit(repository: context.read<FatwaRepository>()),
      child: BlocListener<FatwaLoadingCubit, FatwaLoadingState>(
        listener: (context, state) {
          if (state is FatwaLoadingActionSuccess) {
            Navigator.pop(context); // الخروج عند نجاح الحفظ أو الإرسال
          } else if (state is FatwaLoadingActionError) {
            setState(() {
              _isSaved = false;
            }); // إعادة الفتح للمحاولة
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },

        child: PopScope(
          canPop: _isSaved, // التحكم بالخروج
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _triggerSaveDraft(); // استدعاء دالة الحفظ عند الخروج التلقائي

            Navigator.of(context).pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.fatwa.title),
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      _submitFinalAnswer();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('إرسال الفتوى'),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: _isLoadingPdf
                  ? const Center(child: CircularProgressIndicator())
                  : _pdfController == null
                  ? Center(child: const Text('لا يوجد ملف للعرض'))
                  : Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: PdfEditorView(
                                  controller: _pdfController!,
                                  viewerController:
                                      _viewerController, // ربط متحكم العرض
                                  features: const PdfEditorFeatures(
                                    search: false,
                                  ),
                                ),
                              ),

                              // شريط التكبير (Zoom Bar)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(50),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 40,
                                          ),
                                          onPressed: _zoomOut,
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: TextField(
                                            controller: _zoomTextController,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
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
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 40,
                                          ),
                                          onPressed: _zoomIn,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // شريط الإدخال السفلي
                        Container(
                          color: isDark
                              ? const Color(0xFF121212)
                              : Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isRecordingMode) _buildAudioBar(isDark),
                              if (!_isRecordingMode) _buildTextBar(isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _triggerSaveDraft() async {
    setState(() {
      _isSaved = true;
    });

    Uint8List? finalPdfBytes;

    try {
      // التحقق من وجود المتحكم قبل محاولة استخراج البايتات
      if (_pdfController != null) {
        // ✅ الطريقة الصحيحة: استخدام الخاصية bytes
        finalPdfBytes = _pdfController!.bytes;
      } else {
        throw Exception('متحكم الـ PDF غير مهيأ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تجهيز الـ PDF: $e')));
      setState(() {
        _isSaved = false;
      });
      return;
    }

    if (mounted) {
      context.read<FatwaLoadingCubit>().saveDraft(
        originalFatwa: widget.fatwa,
        textAnswer: _noteController.text,
        audioPath: _audioFilePath,
        editedPdfBytes: finalPdfBytes, // ✅ الآن يحمل البايتات الصحيحة
      );
    }
  }

  Future<void> _submitFinalAnswer() async {
    // 1. تفعيل التصريح بالخروج لتجنب التعليق عند النجاح
    setState(() {
      _isSaved = true;
    });

    Uint8List? finalPdfBytes;

    // 2. استخراج البايتات بأمان من المتحكم
    try {
      if (_pdfController != null) {
        // استخدام الخاصية bytes المتوافقة مع إصدار مكتبتك
        finalPdfBytes = _pdfController!.bytes;
      } else {
        throw Exception('متحكم الـ PDF غير مهيأ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تجهيز الـ PDF: $e')));
      // إعادة المتغير للسماح للمستخدم بالمحاولة مرة أخرى
      setState(() {
        _isSaved = false;
      });
      return;
    }

    // 3. إرسال البيانات للـ Cubit كإرسال نهائي
    if (mounted) {
      context.read<FatwaLoadingCubit>().submitFatwa(
        originalFatwa: widget.fatwa,
        textAnswer: _noteController.text,
        audioPath: _audioFilePath,
        editedPdfBytes: finalPdfBytes, // تمرير البايتات الصحيحة
      );
    }
  }

  Widget _buildTextBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.blue),
            onPressed: () => setState(() => _isRecordingMode = true),
          ),
          Expanded(
            child: TextField(
              controller: _noteController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب إجابتك هنا...',
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _deleteRecording();
              setState(() => _isRecordingMode = false);
            },
          ),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: _hasRecorded
                  ? Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        Expanded(
                          child: AudioFileWaveforms(
                            size: const Size(double.infinity, 40),
                            playerController: _playerController,
                            waveformType: WaveformType.fitWidth,
                            playerWaveStyle: const PlayerWaveStyle(
                              fixedWaveColor: Colors.grey,
                              liveWaveColor: Colors.blue,
                              spacing: 6,
                            ),
                          ),
                        ),
                      ],
                    )
                  : AudioWaveforms(
                      size: const Size(double.infinity, 40),
                      recorderController: _recorderController,
                      waveStyle: const WaveStyle(
                        waveColor: Colors.red,
                        extendWaveform: true,
                        showMiddleLine: false,
                        spacing: 6,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _isRecording ? Colors.red : AppColors.primaryGreen,
            child: IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewerController.viewportChanges.removeListener(
      _updateZoomTextFromController,
    );
    _viewerController.dispose();
    _pdfController?.dispose();
    _zoomTextController.dispose();
    _noteController.dispose();
    _recorderController.dispose();
    _playerController.dispose();
    super.dispose();
  }
}
