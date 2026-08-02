import 'dart:async';
import 'dart:io';
import 'package:fatawa/widgets/fatwa_input_bar.dart';
import 'package:fatawa/widgets/fatwa_pdf_app_bar.dart';
import 'package:fatawa/widgets/pdf_viewer_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_pdf_editor/dart_pdf_editor.dart';

import 'package:fatawa/data/models/fatwa_model.dart';
import 'package:fatawa/data/repositories/fatwa_repository.dart';
import 'package:fatawa/presentation/cubit/fatwa_cubit.dart';
import 'package:fatawa/presentation/cubit/fatwa_loading_cubit.dart';

class FatwaPdfScreen extends StatefulWidget {
  final FatwaModel fatwa;

  const FatwaPdfScreen({super.key, required this.fatwa});

  @override
  State<FatwaPdfScreen> createState() => _FatwaPdfScreenState();
}

class _FatwaPdfScreenState extends State<FatwaPdfScreen> {
  PdfEditingController? _pdfController;
  final Completer<void> _viewportReady = Completer<void>();
  bool _isLoadingPdf = true;
  bool _isSaved = false;

  final GlobalKey<FatwaInputBarState> _inputBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPdf();
    });
  }

  Future<void> _loadPdf() async {
    try {
      Uint8List? bytes;

      if (widget.fatwa.localPdfPath != null &&
          widget.fatwa.localPdfPath!.isNotEmpty) {
        final file = File(widget.fatwa.localPdfPath!);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      }

      if ((bytes == null || bytes.isEmpty) && widget.fatwa.pdfUrl.isNotEmpty) {
        if (widget.fatwa.pdfUrl.startsWith('assets/')) {
          final byteData = await rootBundle.load(widget.fatwa.pdfUrl);
          bytes = byteData.buffer.asUint8List();
        }
      }

      if (bytes != null && bytes.isNotEmpty) {
        _pdfController = PdfEditingController(bytes);
      }

      setState(() => _isLoadingPdf = false);

      if (_pdfController != null) {
        await _viewportReady.future;
      }
    } catch (e) {
      debugPrint('Error loading PDF: $e');
      setState(() => _isLoadingPdf = false);
    }
  }

  Future<void> _triggerSaveDraft() async {
    setState(() => _isSaved = true);

    final currentText =
        _inputBarKey.currentState?.currentText ?? widget.fatwa.textAnswer;
    final currentAudioPath =
        _inputBarKey.currentState?.currentAudioPath ??
        widget.fatwa.localAudioPath;
    String? savedFilePath = widget.fatwa.localPdfPath;

    try {
      if (_pdfController != null) {
        final pdfBytes = _pdfController!.bytes;
        final directory = await getApplicationDocumentsDirectory();
        final safeFileName = widget.fatwa.pdfUrl.replaceAll(
          RegExp(r'[^a-zA-Z0-9]'),
          '_',
        );
        final file = File('${directory.path}/draft_$safeFileName.pdf');

        await file.writeAsBytes(pdfBytes);
        savedFilePath = file.path;
      }

      final updatedModel = widget.fatwa.copyWith(
        textAnswer: currentText,
        localAudioPath: currentAudioPath,
        localPdfPath: savedFilePath,
      );

      if (mounted) {
        await context.read<FatwaCubit>().repository.localDataSource.updateFatwa(
          updatedModel,
        );
      }
    } catch (e) {
      debugPrint('خطأ في حفظ مسودة الـ PDF: $e');
    }
  }

  Future<void> _submitFinalAnswer() async {
    setState(() => _isSaved = true);
    Uint8List? finalPdfBytes;

    try {
      if (_pdfController != null) {
        finalPdfBytes = _pdfController!.bytes;
      } else {
        throw Exception('متحكم الـ PDF غير مهيأ');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تجهيز الـ PDF: $e')));
      setState(() => _isSaved = false);
      return;
    }

    if (mounted) {
      await context.read<FatwaLoadingCubit>().submitFatwa(
        originalFatwa: widget.fatwa,
        textAnswer: _inputBarKey.currentState?.currentText ?? '',
        audioPath: _inputBarKey.currentState?.currentAudioPath,
        editedPdfBytes: finalPdfBytes,
      );
      if (mounted) {
        context.read<FatwaCubit>().loadFatwas();
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showSendConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Center(
              child: Text(
                'تأكيد الإرسال',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد إرسال هذه الفتوى والاعتماد النهائي؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  if (mounted) await _submitFinalAnswer();
                },
                child: const Text('تأكيد وإرسال'),
              ),
            ],
          ),
        );
      },
    );
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
            Navigator.of(context).pop();
          } else if (state is FatwaLoadingActionError) {
            setState(() => _isSaved = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: PopScope(
          canPop: _isSaved,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _inputBarKey.currentState?.stopAllActivities();

            if (context.mounted) {
              await _triggerSaveDraft();
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: FatwaPdfAppBar(
              title: widget.fatwa.title,
              onSendPressed: () async =>
                  await _showSendConfirmationDialog(context),
            ),
            body: SafeArea(
              child: _isLoadingPdf
                  ? const Center(child: CircularProgressIndicator())
                  : _pdfController == null
                  ? const Center(child: Text('لا يوجد ملف للعرض'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                            children: [
                              Expanded(
                                child:PdfViewerArea(
                                          pdfController: _pdfController!,
                                        ),
                              ),
                              Container(
                                decoration: BoxDecoration(color: isDark
                                    ? const Color(0xFF121212)
                                    : Colors.white,
                                    border: Border(top: BorderSide(color: isDark? Colors.grey.shade800  
                                    : Colors.grey.shade300,))),
                                child: FatwaInputBar(
                                  key: _inputBarKey,
                                  fatwa: widget.fatwa,
                                  isLandscapeCompact: false,
                                ),
                              ),
                            ],
                          );
                        
                        // final bool isWideScreen = constraints.maxWidth > 800;
                        // final bool isLandscape =
                        //     constraints.maxWidth > constraints.maxHeight;

                        // if (isWideScreen) {
                        //   return Row(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Expanded(
                        //         flex: 2,
                        //         child: PdfViewerArea(
                        //           pdfController: _pdfController!,
                        //         ),
                        //       ),
                        //       Container(
                        //         width: 340,
                        //         decoration: BoxDecoration(
                        //           color: isDark
                        //               ? const Color(0xFF1E1E1E)
                        //               : Colors.grey.shade50,
                        //           border: Border(
                        //             right: BorderSide(
                        //               color: isDark
                        //                   ? Colors.grey.shade800
                        //                   : Colors.grey.shade300,
                        //               width: 1,
                        //             ),
                        //           ),
                        //         ),
                        //         child: Column(
                        //           // 💡 عمود رئيسي يقسم اللوحة إلى جزأين
                        //           children: [
                        //             // 1. الجزء العلوي (أيقونة والنص) - سيكون قابلاً للتمرير إذا ضاقت المساحة
                        //             Expanded(
                        //               child: SingleChildScrollView(
                        //                 child: Padding(
                        //                   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        //                   child: Column(
                        //                     mainAxisSize: MainAxisSize.min,
                        //                     children: [
                        //                       const SizedBox(
                        //                         height: 4,
                        //                       ), // مسافة علوية لتوسيط الشكل جمالياً
                        //                       Icon(
                        //                         Icons.edit_note_rounded,
                        //                         size: 50,
                        //                         color: Colors.grey.shade400,
                        //                       ),
                        //                       const SizedBox(height: 12),
                        //                       Text(
                        //                         'مساحة الرد والتعليق',
                        //                         style: TextStyle(
                        //                           color: isDark
                        //                               ? Colors.white70
                        //                               : Colors.grey.shade700,
                        //                           fontSize: 16,
                        //                           fontWeight: FontWeight.bold,
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ),
                        //             ),
                        //             const SizedBox(height: 20),
                        //             // 2. حقل الإدخال والتسجيل - سيبقى مثبتاً في الأسفل وفوق الكيبورد تماماً
                        //             Container(
                        //               padding: const EdgeInsets.all(8.0),
                        //               decoration: BoxDecoration(
                        //                 color: isDark
                        //                     ? const Color(0xFF1E1E1E)
                        //                     : Colors.white,
                        //                 border: Border(
                        //                   top: BorderSide(
                        //                     color: isDark
                        //                         ? Colors.grey.shade800
                        //                         : Colors.grey.shade300,
                        //                     width: 1,
                        //                   ),
                        //                 ),
                        //               ),
                        //               child: FatwaInputBar(
                        //                 key: _inputBarKey,
                        //                 fatwa: widget.fatwa,
                        //                 isLandscapeCompact: true,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   );
                        // } else {
                        //   return Column(
                        //     children: [
                        //       Expanded(
                        //         child: Navigator(
                        //           onGenerateRoute: (settings) {
                        //             return MaterialPageRoute(
                        //               builder: (context) => Scaffold(
                        //                 body: PdfViewerArea(
                        //                   pdfController: _pdfController!,
                        //                 ),
                        //               ),
                        //             );
                        //           },
                        //         ),
                        //       ),
                        //       Container(
                        //         color: isDark
                        //             ? const Color(0xFF121212)
                        //             : Colors.white,
                        //         child: FatwaInputBar(
                        //           key: _inputBarKey,
                        //           fatwa: widget.fatwa,
                        //           isLandscapeCompact: isLandscape,
                        //         ),
                        //       ),
                        //     ],
                        //   );
                        // }
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }
}
