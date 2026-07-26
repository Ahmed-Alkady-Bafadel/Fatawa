import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fatawa/data/models/fatwa_model.dart';
import 'package:fatawa/data/repositories/fatwa_repository.dart';
import 'package:fatawa/presentation/cubit/fatwa_cubit.dart';
import 'package:fatawa/presentation/cubit/fatwa_loading_cubit.dart';
import 'package:flutter/material.dart';
import 'package:dart_pdf_editor/dart_pdf_editor.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';

class FatwaPdfScreen extends StatefulWidget {
  final FatwaModel fatwa;

  const FatwaPdfScreen({super.key, required this.fatwa});

  @override
  State<FatwaPdfScreen> createState() => _FatwaPdfScreenState();
}

class _FatwaPdfScreenState extends State<FatwaPdfScreen> {
  // مراقبات حالة المشغل
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompletionSubscription;
  StreamSubscription<int>? _durationSubscription;

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
  bool _hasRecorded = false;
  bool _isPlaying = false;
  bool _isSaved = false;
  String? _audioFilePath;
  int _currentDuration = 0; // لتتبع مكان النقطة الخضراء

  // 1) في initState()
@override
void initState() {
  super.initState();
  _recorderController = RecorderController();
  _playerController = PlayerController();
  _initPlayerListeners();

  _checkExistingAudio();
  _viewerController = PdfViewerController();
  _viewerController.viewportChanges.addListener(_updateZoomTextFromController);
  _zoomTextController = TextEditingController();
  _noteController = TextEditingController(text: widget.fatwa.textAnswer ?? '');

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadPdf();
  });
}


  Future<void> _checkExistingAudio() async {
    final savedPath = widget.fatwa.localAudioPath;

    if (savedPath != null && savedPath.isNotEmpty) {
      _audioFilePath = savedPath;
      _hasRecorded = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted && _audioFilePath != null) {
          await _playerController.preparePlayer(
            path: _audioFilePath!,
            shouldExtractWaveform: true,
          );

          if (mounted) setState(() {});
        }
      });
    }
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

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorderController.checkPermission();
      if (!hasPermission) return;

      final dir = await getApplicationDocumentsDirectory();
      _audioFilePath =
          '${dir.path}/fatwa_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorderController.record(path: _audioFilePath);
      setState(() => _isRecordingMode = true);
    } catch (e) {
      print('خطأ في بدء التسجيل: $e');
    }
  }

  // 5) عدّل _stopRecording() بهذا الشكل
Future<void> _stopRecording() async {
  try {
    final tempPath = await _recorderController.stop();

    if (tempPath != null && tempPath.isNotEmpty) {
      widget.fatwa.localAudioPath = tempPath;
      context.read<FatwaCubit>().updateFatawa(widget.fatwa);

      if (mounted) {
        setState(() {
          _audioFilePath = tempPath;
          _isRecordingMode = false;
          _hasRecorded = true;
          _currentDuration = 0;
          _isPlaying = false;
        });
      }

      

      await _playerController.preparePlayer(
        path: tempPath,
        shouldExtractWaveform: true,
      );

      if (mounted) {
        setState(() {
        });
      }
    }
  } catch (e, s) {
    debugPrint('Error stopping recording: $e');
    debugPrintStack(stackTrace: s);

    if (mounted) {
      setState(() {
        _isRecordingMode = false;
      });
    }
  }
}


  // 4) استبدل _deleteRecording()
Future<void> _deleteRecording() async {
  await _resetPlayerController();

  widget.fatwa.localAudioPath = null;
  context.read<FatwaCubit>().updateFatawa(widget.fatwa);

  if (!mounted) return;
  setState(() {
    _hasRecorded = false;
    _audioFilePath = null;
    _currentDuration = 0;
    _isPlaying = false;
    _isSaved = false;
  });
}


  Future<void> _togglePlayPause() async {
    try {
      if (_playerController.playerState == PlayerState.playing) {
        await _playerController.pausePlayer();
      } else {
        if (_playerController.playerState == PlayerState.stopped &&
            _audioFilePath != null) {
          await _playerController.preparePlayer(
            path: _audioFilePath!,
            shouldExtractWaveform: false,
          );
        }
        await _playerController.startPlayer();
      }
    } catch (e) {
      debugPrint('خطأ في تشغيل الصوت: $e');
    }
  }

  // 2) أضف هذه الدالة داخل الـ State
void _initPlayerListeners() {
  _playerStateSubscription = _playerController.onPlayerStateChanged.listen((state) {
    if (!mounted) return;
    setState(() {
      _isPlaying = state == PlayerState.playing;
    });
  });

  _playerCompletionSubscription = _playerController.onCompletion.listen((_) async {
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _currentDuration = 0;
    });

    try {
      await _playerController.seekTo(0);
    } catch (_) {}
  });

  _durationSubscription = _playerController.onCurrentDurationChanged.listen((duration) {
    if (mounted && _playerController.playerState == PlayerState.playing) {
      setState(() {
        _currentDuration = duration;
      });
    }
  });
}

  // 3) أضف هذه الدالة لإعادة ضبط المشغل بعد الحذف
Future<void> _resetPlayerController() async {
  try {
    await _playerController.stopPlayer();
  } catch (_) {}

  try {
    _playerController.release();
  } catch (_) {}

  await _playerStateSubscription?.cancel();
  await _playerCompletionSubscription?.cancel();
  await _durationSubscription?.cancel();

  _playerStateSubscription = null;
  _playerCompletionSubscription = null;
  _durationSubscription = null;

  _playerController.dispose();
  _playerController = PlayerController();
  _initPlayerListeners();
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
            try {
              if (_isRecordingMode) {
                await _recorderController.stop();
              }
              if (_playerController.playerState == PlayerState.playing) {
                await _playerController.stopPlayer();
              }
            } catch (e) {}

            if (context.mounted) {
              await _triggerSaveDraft(); // استدعاء دالة الحفظ عند الخروج التلقائي

              Navigator.of(context).pop();
            }
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
                              _buildTextBar(isDark),
                              if (_isRecordingMode || _hasRecorded)
                                _buildAudioBar(isDark),
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

    final currentText = _noteController.text;
    final currentAudioPath = widget.fatwa.localAudioPath ?? _audioFilePath;
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
      final updatedModel = widget.fatwa.copyWith(
        textAnswer: currentText,
        localAudioPath: currentAudioPath,
      );

      context.read<FatwaCubit>().updateFatawa(updatedModel);

      context.read<FatwaLoadingCubit>().saveDraft(
        originalFatwa: widget.fatwa,
        textAnswer: currentText,
        audioPath: currentAudioPath,
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
          if (!_isRecordingMode && !_hasRecorded)
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.blue),
              onPressed: () async {
                setState(() {
                  _isRecordingMode = true;
                });
                await _startRecording();
              },
            ),
          Expanded(
            child: TextField(
              controller: _noteController,
              onChanged: (text) {
                widget.fatwa.textAnswer = text;
                context.read<FatwaCubit>().updateFatawa(widget.fatwa);
              },
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            // ----------------------------------------------------
            // الحالة الأولى: جاري التسجيل (زر إيقاف + موجات حية)
            // ----------------------------------------------------
            if (_isRecordingMode) ...[
              // زر الإيقاف الأحمر
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.stop, color: Colors.white),
                    onPressed: _stopRecording,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // موجات التسجيل الحية (من الكود الخاص بك)
              Expanded(
                child: AudioWaveforms(
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
            ]
            // ----------------------------------------------------
            // الحالة الثانية: تم التسجيل
            // ----------------------------------------------------
            else if (_hasRecorded) ...[
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.primaryGreen,
                ),
              ),

              // منطقة الصوت والنقطة الخضراء
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    final double maxDur = _playerController.maxDuration > 0
                        ? _playerController.maxDuration.toDouble()
                        : 1.0;
                    final double currentVal = _currentDuration.toDouble().clamp(
                      0.0,
                      maxDur,
                    );

                    return SizedBox(
                      width: width,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. الذبذبات
                          AudioFileWaveforms(
                            key: ValueKey(_audioFilePath),
                            size: Size(width, 40),
                            playerController: _playerController,
                            enableSeekGesture: false,
                            waveformType: WaveformType.fitWidth,
                            playerWaveStyle: PlayerWaveStyle(
                              fixedWaveColor: Colors.grey.shade400,
                              liveWaveColor: Colors.grey.shade400,
                              spacing: 5,
                              showSeekLine: false,
                            ),
                          ),

                          // 2. النقطة الخضراء
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackShape: CustomTrackShape(),
                              trackHeight: 40,
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: const Color(0xFF00B09B),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              min: 0.0,
                              max: maxDur,
                              value: currentVal,
                              onChangeStart: (value) {
                                if (_isPlaying) _playerController.pausePlayer();
                              },
                              onChanged: (value) {
                                setState(() {
                                  _currentDuration = value.toInt();
                                });
                                _playerController.seekTo(value.toInt());
                              },
                              onChangeEnd: (value) async {
                                await _playerController.seekTo(value.toInt());
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteRecording,
              ),
            ],
          ],
        ),
      ),
    );
  }

// 7) وفي dispose() كما هو، لكن تأكد من بقاء الإلغاء قبل dispose()
@override
void dispose() {
  _playerStateSubscription?.cancel();
  _playerCompletionSubscription?.cancel();
  _durationSubscription?.cancel();

  _viewerController.viewportChanges.removeListener(_updateZoomTextFromController);

  _viewerController.dispose();
  _pdfController?.dispose();
  _zoomTextController.dispose();
  _noteController.dispose();

  _recorderController.dispose();
  _playerController.dispose();

  super.dispose();
}

}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth =
        parentBox.size.width; // نأخذ العرض بالكامل ليتطابق مع الذبذبات
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
