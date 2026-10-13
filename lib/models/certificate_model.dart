import 'package:cloud_firestore/cloud_firestore.dart';

class CertificateModel {
  final String id;
  final String uid;
  final String title;
  final String issuer;
  final String? imageUrl;
  final DateTime? issueDate;
  final String verificationCode;
  final bool isVerified;

  CertificateModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.issuer,
    this.imageUrl,
    this.issueDate,
    this.verificationCode = '',
    this.isVerified = false,
  });

  factory CertificateModel.fromMap(String id, Map<String, dynamic> data) {
    return CertificateModel(
      id: id,
      uid: data['uid'] ?? '',
      title: data['title'] ?? 'شهادة بدون عنوان',
      issuer: data['issuer'] ?? 'UniWork Hub',
      imageUrl: data['imageUrl'],
      issueDate: (data['issueDate'] as Timestamp?)?.toDate(),
      verificationCode: data['verificationCode'] ?? '',
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'issuer': issuer,
      'imageUrl': imageUrl,
      'issueDate': issueDate ?? FieldValue.serverTimestamp(),
      'verificationCode': verificationCode,
      'isVerified': isVerified,
    };
  }

  String get formattedDate {
    if (issueDate == null) return 'غير محدد';
    return '${issueDate!.year}/${issueDate!.month}/${issueDate!.day}';
  }
}