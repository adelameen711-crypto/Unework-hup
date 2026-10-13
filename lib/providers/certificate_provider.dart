import 'package:flutter/material.dart';
import '../models/certificate_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CertificateProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<CertificateModel> _certificates = [];
  CertificateModel? _currentCertificate;
  bool _isLoading = false;
  String? _errorMessage;

  // ===== Getters =====
  List<CertificateModel> get certificates => _certificates;
  CertificateModel? get currentCertificate => _currentCertificate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ===== تحميل الشهادات =====
  Future<void> loadCertificates() async {
    final user = _authService.currentUser;
    if (user == null) {
      _errorMessage = 'يرجى تسجيل الدخول أولاً';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getCertificatesForUser(user.uid).first;
      _certificates = snapshot.docs.map((doc) {
        return CertificateModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل الشهادات: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== إضافة شهادة جديدة =====
  Future<bool> addCertificate({
    required String title,
    required String issuer,
    String? imageUrl,
    String? verificationCode,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      _errorMessage = 'يرجى تسجيل الدخول أولاً';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final certificate = CertificateModel(
        id: _firestoreService.generateId(),
        uid: user.uid,
        title: title,
        issuer: issuer,
        imageUrl: imageUrl,
        issueDate: DateTime.now(),
        verificationCode: verificationCode ?? _generateVerificationCode(),
        isVerified: false,
      );

      final certId = await _firestoreService.createCertificate(certificate);
      final newCertificate = CertificateModel(
        id: certId,
        uid: user.uid,
        title: title,
        issuer: issuer,
        imageUrl: imageUrl,
        issueDate: DateTime.now(),
        verificationCode: verificationCode ?? _generateVerificationCode(),
        isVerified: false,
      );

      _certificates.insert(0, newCertificate);

      // ✅ تحديث قائمة الشهادات في UserModel
      await _updateUserCertificates(user.uid, certId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إضافة الشهادة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== حذف شهادة =====
  Future<bool> deleteCertificate(String certificateId) async {
    final user = _authService.currentUser;
    if (user == null) {
      _errorMessage = 'يرجى تسجيل الدخول أولاً';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // حذف من Firestore
      await _firestoreService.deleteCertificate(certificateId);

      // حذف من القائمة المحلية
      _certificates.removeWhere((cert) => cert.id == certificateId);

      // ✅ تحديث قائمة الشهادات في UserModel
      await _removeUserCertificate(user.uid, certificateId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في حذف الشهادة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== التحقق من صحة الشهادة =====
  Future<bool> verifyCertificate(String certificateId) async {
    try {
      await _firestoreService.verifyCertificate(certificateId);
      
      final index = _certificates.indexWhere((cert) => cert.id == certificateId);
      if (index != -1) {
        _certificates[index] = CertificateModel(
          id: _certificates[index].id,
          uid: _certificates[index].uid,
          title: _certificates[index].title,
          issuer: _certificates[index].issuer,
          imageUrl: _certificates[index].imageUrl,
          issueDate: _certificates[index].issueDate,
          verificationCode: _certificates[index].verificationCode,
          isVerified: true,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في التحقق من الشهادة: $e';
      notifyListeners();
      return false;
    }
  }

  // ===== الحصول على شهادة بواسطة ID =====
  CertificateModel? getCertificateById(String id) {
    try {
      return _certificates.firstWhere((cert) => cert.id == id);
    } catch (e) {
      return null;
    }
  }

  // ===== الحصول على الشهادات الموثقة =====
  List<CertificateModel> get verifiedCertificates {
    return _certificates.where((cert) => cert.isVerified).toList();
  }

  // ===== الحصول على الشهادات غير الموثقة =====
  List<CertificateModel> get unverifiedCertificates {
    return _certificates.where((cert) => !cert.isVerified).toList();
  }

  // ===== دوال مساعدة خاصة =====
  String _generateVerificationCode() {
    final now = DateTime.now();
    final random = DateTime.now().microsecondsSinceEpoch.toString().substring(0, 6);
    return 'UNIW-${now.year}-${now.month}-$random';
  }

  Future<void> _updateUserCertificates(String uid, String certId) async {
    final user = await _firestoreService.getUser(uid);
    if (user != null) {
      final updatedCertificates = List<String>.from(user.certificates)..add(certId);
      await _firestoreService.updateUser(uid, {
        'certificates': updatedCertificates,
      });
    }
  }

  Future<void> _removeUserCertificate(String uid, String certId) async {
    final user = await _firestoreService.getUser(uid);
    if (user != null) {
      final updatedCertificates = List<String>.from(user.certificates)..remove(certId);
      await _firestoreService.updateUser(uid, {
        'certificates': updatedCertificates,
      });
    }
  }

  // ===== مسح رسالة الخطأ =====
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}