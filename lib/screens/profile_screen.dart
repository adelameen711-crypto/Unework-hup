import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/pdf_generator.dart';
import '../widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userData;

    return AppScaffold(
      currentIndex: 3,
      title: 'البصمة المهنية',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('سيتم إضافة تعديل الملف الشخصي قريباً')),
            );
          },
          tooltip: 'تعديل الملف الشخصي',
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== صورة المستخدم =====
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // ===== الاسم مع زر التعديل =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.name ?? 'مستخدم',
                  style: AppTextStyles.headline1,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('سيتم إضافة تعديل الملف الشخصي قريباً')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(user?.email ?? 'البريد غير متوفر', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),

            // ===== الإحصائيات =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat('${user?.skillCount ?? 0}', 'مهارة', Icons.stars, Colors.amber),
                _buildStat('${user?.projectCount ?? 0}', 'مشروع', Icons.code, Colors.blue),
                _buildStat('${user?.certificateCount ?? 0}', 'شهادة', Icons.verified, Colors.green),
                _buildStat(user?.rating.toStringAsFixed(1) ?? '0.0', 'تقييم', Icons.star, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // ===== المهارات =====
            const Text('المهارات', style: AppTextStyles.headline2),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (user?.skills.keys.toList() ?? ['Flutter', 'Firebase', 'Dart']).map((skill) {
                return Chip(
                  label: Text(skill),
                  backgroundColor: AppColors.primaryLight,
                  labelStyle: const TextStyle(color: AppColors.primary),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ===== زر تصدير PDF =====
            ElevatedButton.icon(
              onPressed: () async {
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لا توجد بيانات لتصديرها')),
                  );
                  return;
                }
                await PdfGenerator.generateCertificate(
                  studentName: user.name,
                  date: DateTime.now().toString().split(' ')[0],
                  certificateId: 'UNIW-${DateTime.now().year}-${user.uid.substring(0, 6)}',
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('تصدير السيرة الذاتية PDF'),
            ),
            const SizedBox(height: 16),

            // ===== عرض الشهادات =====
            OutlinedButton.icon(
              onPressed: () => context.go('/certificates'),
              icon: const Icon(Icons.verified),
              label: const Text('عرض الشهادات'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}