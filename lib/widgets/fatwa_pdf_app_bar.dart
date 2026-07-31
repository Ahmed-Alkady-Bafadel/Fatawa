import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FatwaPdfAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSendPressed;

  const FatwaPdfAppBar({
    super.key,
    required this.title,
    required this.onSendPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(fontSize: 18)),
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
            onPressed: onSendPressed,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('إرسال الفتوى'),
          ),
        ),
      ],
    );
  }
}
