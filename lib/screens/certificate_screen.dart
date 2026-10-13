import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/pdf_generator.dart';
import '../widgets/app_scaffold.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 3,
      title: 'الشهادات الرقمية',
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: () {
            // TODO: Download all certificates
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('جاري تحميل جميع الشهادات...')),
            );
          },
          tooltip: 'تحميل الكل',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('جاري تصفية الشهادات...')),
            );
          },
          tooltip: 'تصفية',
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCertificateCard(
            context,
            'شهادة Flutter Complete Guide',
            'Udemy',
            '2024',
            'UNIW-2024-001',
          ),
          const SizedBox(height: 12),
          _buildCertificateCard(
            context,
            'شهادة Firebase Associate',
            'Google',
            '2024',
            'UNIW-2024-002',
          ),
          const SizedBox(height: 12),
          _buildCertificateCard(
            context,
            'شهادة إدارة المشاريع',
            'UniWork Hub',
            '2024',
            'UNIW-2024-003',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(
    BuildContext context,
    String title,
    String issuer,
    String year,
    String code,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.verified, color: AppColors.success, size: 32),
        title: Text(title, style: AppTextStyles.headline3),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$issuer • $year'),
            Text('🔑 $code', style: AppTextStyles.bodySmall),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
          onPressed: () async {
            await PdfGenerator.generateCertificate(
              studentName: 'علي الشيخ',
              date: DateTime.now().toString().split(' ')[0],
              certificateId: code,
            );
          },
          tooltip: 'تحميل PDF',
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الجهة المانحة: $issuer'),
                  Text('التاريخ: $year'),
                  Text('رمز التحقق: $code'),
                  const SizedBox(height: 8),
                  const Text(
                    '✅ هذه الشهادة موثقة',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await PdfGenerator.generateCertificate(
                      studentName: 'علي الشيخ',
                      date: DateTime.now().toString().split(' ')[0],
                      certificateId: code,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('تحميل PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}