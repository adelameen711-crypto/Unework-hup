import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../core/utils/pdf_generator.dart';
import 'certificate_provider.dart';

class ProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _qrData;

  // ===== Getters =====
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get qrData => _qrData;

  // ===== تحميل الملف الشخصي =====
  Future<void> loadProfile() async {
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
      final profile = await _firestoreService.getUser(user.uid);
      if (profile != null) {
        _userProfile = profile;
        _generateQRData();
      } else {
        _userProfile = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'مستخدم',
          email: user.email ?? '',
        );
        await _firestoreService.saveUser(_userProfile!);
        _generateQRData();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل الملف الشخصي: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== إضافة مهارة =====
  Future<bool> addSkill(String skill, String level) async {
    if (_userProfile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedSkills = Map<String, String>.from(_userProfile!.skills);
      updatedSkills[skill] = level;

      await _firestoreService.updateUser(_userProfile!.uid, {
        'skills': updatedSkills,
      });

      _userProfile = _userProfile!.copyWith(skills: updatedSkills);
      _generateQRData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إضافة المهارة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== حذف مهارة =====
  Future<bool> removeSkill(String skill) async {
    if (_userProfile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedSkills = Map<String, String>.from(_userProfile!.skills);
      updatedSkills.remove(skill);

      await _firestoreService.updateUser(_userProfile!.uid, {
        'skills': updatedSkills,
      });

      _userProfile = _userProfile!.copyWith(skills: updatedSkills);
      _generateQRData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في حذف المهارة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== إضافة شهادة =====
  Future<bool> addCertificate({
    required String title,
    required String issuer,
    String? imageUrl,
  }) async {
    if (_userProfile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final certProvider = CertificateProvider();
      final success = await certProvider.addCertificate(
        title: title,
        issuer: issuer,
        imageUrl: imageUrl,
      );
      
      if (success) {
        await loadProfile();
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إضافة الشهادة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== تحديث الملف الشخصي =====
  Future<bool> updateProfile({
    String? name,
    String? major,
    int? year,
    double? gpa,
  }) async {
    if (_userProfile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (major != null) data['major'] = major;
      if (year != null) data['year'] = year;
      if (gpa != null) data['gpa'] = gpa;

      if (data.isNotEmpty) {
        await _firestoreService.updateUser(_userProfile!.uid, data);
        _userProfile = _userProfile!.copyWith(
          name: name ?? _userProfile!.name,
          major: major ?? _userProfile!.major,
          year: year ?? _userProfile!.year,
          gpa: gpa ?? _userProfile!.gpa,
        );
        _generateQRData();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحديث الملف الشخصي: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== إنشاء بيانات QR =====
  void _generateQRData() {
    if (_userProfile == null) return;

    final data = {
      'name': _userProfile!.name,
      'email': _userProfile!.email,
      'major': _userProfile!.major,
      'skills': _userProfile!.skills.keys.toList(),
      'rating': _userProfile!.rating,
    };

    _qrData = jsonEncode(data);
    notifyListeners();
  }

  // ===== تصدير السيرة الذاتية PDF =====
  Future<void> exportPDF() async {
    if (_userProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await PdfGenerator.generateCertificate(
        studentName: _userProfile!.name,
        date: DateTime.now().toString().split(' ')[0],
        certificateId: 'UNIW-${DateTime.now().year}-${_userProfile!.uid.substring(0, 6)}',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تصدير PDF: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== مسح رسالة الخطأ =====
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}