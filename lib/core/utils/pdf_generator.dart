import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  // ===== إنشاء تقرير المشروع =====
  static Future<void> generateProjectReport({
    required String projectName,
    required String teamMembers,
    required String date,
    required List<String> features,
    required Map<String, double> evaluation,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'UniWork Hub',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'تقرير المشروع النهائي',
                  style: pw.TextStyle(fontSize: 18),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('📅 التاريخ: $date'),
              pw.Text('👥 الفريق: $teamMembers'),
              pw.SizedBox(height: 16),
              pw.Text(
                '📌 ملخص المشروع',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              pw.Text(
                'تطبيق UniWork Hub هو منصة لإدارة المشاريع الجماعية والتوثيق المهني.',
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                '✅ الميزات المنفذة',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              ...features.map((f) => pw.Text('✓ $f')),
              pw.SizedBox(height: 12),
              pw.Text(
                '🏆 التقييم النهائي',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
              ...evaluation.entries.map((e) => pw.Text('${e.key}: ${e.value}/5')),
              pw.SizedBox(height: 16),
              pw.Text('─' * 40),
              pw.Text('[توقيع القائد]'),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Project_Report_$projectName.pdf',
    );
  }

  // ===== إنشاء شهادة تقدير =====
  static Future<void> generateCertificate({
    required String studentName,
    required String date,
    required String certificateId,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  '🏆 شهادة تقدير 🏆',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'تمنح هذه الشهادة لـ',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  studentName,
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'نظير إنجازه المتميز في مشروع UniWork Hub',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 16),
                pw.Text('📅 التاريخ: $date'),
                pw.Text('🔑 رمز التحقق: $certificateId'),
                pw.SizedBox(height: 16),
                pw.Text('─' * 40),
                pw.Text('[توقيع القائد]'),
                pw.SizedBox(height: 8),
                pw.Text(
                  '* هذه الشهادة رقمية وتحتوي على رمز تحقق يمكن التحقق منه عبر التطبيق',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Certificate_$studentName.pdf',
    );
  }
}