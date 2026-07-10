import 'package:fatawa/models/fatwa_model.dart';
import 'package:fatawa/widgets/fatwa_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key}); 

  // دالة إظهار نافذة تأكيد الخروج (Dialog)
  Future<bool> _showExitDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.exit_to_app, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              'الخروج من التطبيق',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد أنك تريد الخروج من التطبيق نهائياً؟',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), 
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true), 
            child: const Text('نعم، متأكد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context);
        if (shouldExit) {
          SystemNavigator.pop(); 
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FDF9),
          elevation: 0,
          title: Image.asset(
            'assets/images/logo-calligraphy.png', 
            height: 40,
            fit: BoxFit.contain,
          ),
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: AppColors.primaryGreen,
              ),
              onPressed: () {
                // منطق التبديل بين الثيم المظلم والفاتح
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.redAccent,
              ),
              onPressed: () async {
                final shouldExit = await _showExitDialog(context);
                if (shouldExit) {
                  SystemNavigator.pop(); 
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        
        body: ListView.separated(
          physics: const BouncingScrollPhysics(), 
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 5, 
          separatorBuilder: (context, index) => Divider(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            height: 1,
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            return const FatwaCardWidget(
              fatwa: FatwaModel(
                title: 'حكم الصلاة في الطائرة',
                questionSnippet: 'هل يجوز لي أداء صلاة الفريضة وأنا جالس في مقعد الطائرة إذا كنت أخشى خروج الوقت؟',
                date: '6/24',
                pdfUrl: '',
              ),
            );
          },
        ),
      ),
    );
  }
}
