import 'package:fatawa/data/models/fatwa_model.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FatwaCardWidget extends StatelessWidget {
  final FatwaModel fatwa;

  const FatwaCardWidget({super.key, required this.fatwa});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // الانتقال لشاشة تفاصيل الفتوى لاحقاً
        },
        splashColor: AppColors.primaryGreen.withAlpha(26),
        highlightColor: AppColors.primaryGreen.withAlpha(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // القسم الأيمن: عنوان الفتوى ومقتطف السؤال
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fatwa.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fatwa.questionSnippet ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey[400]
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // القسم الأيسر: تاريخ وصول الفتوى
              Text(
                fatwa.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
