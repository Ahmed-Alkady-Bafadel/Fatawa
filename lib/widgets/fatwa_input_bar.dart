import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fatawa/data/models/fatwa_model.dart';
import 'package:fatawa/presentation/cubit/fatwa_cubit.dart';
import '../../../core/theme/app_colors.dart';

class FatwaInputBar extends StatefulWidget {
  final FatwaModel fatwa;
  final bool isLandscapeCompact;

  const FatwaInputBar({
    super.key,
    required this.fatwa,
    required this.isLandscapeCompact,
  });

  @override
  State<FatwaInputBar> createState() => FatwaInputBarState();
}

class FatwaInputBarState extends State<FatwaInputBar> {
  late TextEditingController _noteController;
  late RecorderController _recorderController;
  late PlayerController _playerController;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompletionSubscription;
  StreamSubscription<int>? _durationSubscription;

  bool _isRecordingMode = false;
  bool _hasRecorded = false;
  bool _isPlaying = false;
  bool _wasPlayingBeforeSeek = false;
  String? _audioFilePath;
  int _currentDuration = 0;

  String get currentText => _noteController.text;
  String? get currentAudioPath => _audioFilePath;

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController();
    _playerController = PlayerController();
    _initPlayerListeners();

    _noteController = TextEditingController(
      text: widget.fatwa.textAnswer ?? '',
    );
    _checkExistingAudio();
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

  Future<void> stopAllActivities() async {
    try {
      if (_isRecordingMode) await _recorderController.stop();
      if (_playerController.playerState == PlayerState.playing) {
        await _playerController.stopPlayer();
      }
    } catch (_) {}
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorderController.checkPermission();
      if (!hasPermission) return;
      _audioFilePath = null;
      final dir = await getApplicationDocumentsDirectory();
      _audioFilePath =
          '${dir.path}/fatwa_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorderController.record(path: _audioFilePath);
      setState(() => _isRecordingMode = true);
    } catch (e) {
      debugPrint('خطأ في بدء التسجيل: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final tempPath = await _recorderController.stop();
      if (tempPath != null && tempPath.isNotEmpty) {
        final updateFatws = widget.fatwa.copyWith(localAudioPath: tempPath);
        widget.fatwa.localAudioPath = tempPath;
        context.read<FatwaCubit>().repository.localDataSource.updateFatwa(
          updateFatws,
        );

        await _playerController.preparePlayer(
          path: tempPath,
          shouldExtractWaveform: true,
        );

        if (mounted) {
          setState(() {
            _audioFilePath = tempPath;
            _isRecordingMode = false;
            _hasRecorded = true;
            _currentDuration = 0;
            _isPlaying = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isRecordingMode = false);
    }
  }

  Future<void> _deleteRecording() async {
    try {
      await stopAllActivities();
      if (_audioFilePath != null) {
        final file = File(_audioFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      widget.fatwa.localAudioPath = null;

      _playerController.dispose();
      _playerController = PlayerController();

      _durationSubscription?.cancel();
      _durationSubscription = _playerController.onCurrentDurationChanged.listen(
        (duration) {
          if (mounted && _playerController.playerState == PlayerState.playing) {
            setState(() {
              _currentDuration = duration;
            });
          }
        },
      );

      _playerCompletionSubscription = _playerController.onCompletion.listen((
        _,
      ) async {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentDuration = 0;
          });
        }
        try {
          await _playerController.seekTo(0);
        } catch (_) {}
      });

      if (mounted) {
        setState(() {
          _hasRecorded = false;
          _audioFilePath = null;
          _isRecordingMode = false;
          _currentDuration = 0;
          _isPlaying = false;
        });
      }
    } catch (e) {}
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

  void _initPlayerListeners() {
    _playerStateSubscription = _playerController.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _playerCompletionSubscription = _playerController.onCompletion.listen((
      _,
    ) async {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentDuration = 0;
        });
      }
      try {
        await _playerController.seekTo(0);
      } catch (_) {}
    });

    _durationSubscription = _playerController.onCurrentDurationChanged.listen((
      duration,
    ) {
      if (mounted && _playerController.playerState == PlayerState.playing) {
        setState(() => _currentDuration = duration);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextBar(isDark),
        if (_isRecordingMode || _hasRecorded) _buildAudioBar(isDark),
      ],
    );
  }

  Widget _buildTextBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (!_isRecordingMode && !_hasRecorded)
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.blue),
              onPressed: _startRecording,
            ),
          Expanded(
            child: TextField(
              controller: _noteController,
              onChanged: (text) {
                widget.fatwa.textAnswer = text;
              },
              minLines: 1,
              
              decoration: InputDecoration(
                hintText: 'اكتب إجابتك هنا...',
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            if (_isRecordingMode) ...[
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
            ] else if (_hasRecorded) ...[
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.primaryGreen,
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxDur = _playerController.maxDuration > 0
                        ? _playerController.maxDuration.toDouble()
                        : 1.0;
                    final double currentVal = _currentDuration.toDouble().clamp(
                      0.0,
                      maxDur,
                    );

                    return SizedBox(
                      width: constraints.maxWidth,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AudioFileWaveforms(
                            key: ValueKey(_audioFilePath),
                            size: Size(constraints.maxWidth, 40),
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
                              onChangeStart: (_) {
                                _wasPlayingBeforeSeek = _isPlaying;
                                if (_isPlaying) _playerController.pausePlayer();
                              },
                              onChanged: (value) {
                                setState(
                                  () => _currentDuration = value.toInt(),
                                );
                                _playerController.seekTo(value.toInt());
                              },
                              onChangeEnd: (value) async {
                                await _playerController.seekTo(value.toInt());
                                if (_wasPlayingBeforeSeek) {
                                  await _playerController.startPlayer();
                                }
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

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _playerCompletionSubscription?.cancel();
    _durationSubscription?.cancel();
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
    return Rect.fromLTWH(
      trackLeft,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
  }
}
