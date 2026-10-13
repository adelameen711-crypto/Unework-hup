import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class TeamProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<TeamModel> _teams = [];
  TeamModel? _currentTeam;
  bool _isLoading = false;
  String? _errorMessage;

  // ===== Getters =====
  List<TeamModel> get teams => _teams;
  TeamModel? get currentTeam => _currentTeam;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ===== تحميل المشاريع =====
  Future<void> loadTeams() async {
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
      final snapshot = await _firestoreService.getTeamsForUser(user.uid).first;
      _teams = snapshot.docs.map((doc) {
        return TeamModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل المشاريع: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== إنشاء مشروع جديد =====
  Future<bool> createTeam({
    required String projectName,
    required String description,
    DateTime? deadline,
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
      final team = TeamModel(
        id: _firestoreService.generateId(),
        projectName: projectName,
        description: description,
        leaderId: user.uid,
        memberIds: [user.uid],
        memberNames: [user.displayName ?? 'مستخدم'],
        deadline: deadline,
        status: 'active',
      );

      final teamId = await _firestoreService.createTeam(team);
      final newTeam = TeamModel(
        id: teamId,
        projectName: projectName,
        description: description,
        leaderId: user.uid,
        memberIds: [user.uid],
        memberNames: [user.displayName ?? 'مستخدم'],
        deadline: deadline,
        status: 'active',
      );

      _teams.insert(0, newTeam);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إنشاء المشروع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== الحصول على مشروع محدد =====
  Future<TeamModel?> getTeam(String teamId) async {
    try {
      final team = await _firestoreService.getTeam(teamId);
      if (team != null) {
        _currentTeam = team;
        notifyListeners();
      }
      return team;
    } catch (e) {
      _errorMessage = 'حدث خطأ في جلب المشروع: $e';
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // ✅ البحث عن مستخدم بالبريد الإلكتروني (معدل)
  // ============================================================
  Future<UserModel?> _findUserByEmail(String email) async {
    try {
      final snapshot = await _firestoreService.getAllUsers();
      final users = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      // ✅ استخدام where مع firstOrNull (الأفضل)
      return users.where(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      ).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // ===== إضافة عضو إلى المشروع =====
  Future<bool> addMember(String teamId, String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final team = await _firestoreService.getTeam(teamId);
      if (team == null) {
        _errorMessage = 'المشروع غير موجود';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = await _findUserByEmail(email);
      if (user == null) {
        _errorMessage = 'المستخدم غير موجود';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (team.memberIds.contains(user.uid)) {
        _errorMessage = 'هذا المستخدم عضو بالفعل في المشروع';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedMemberIds = List<String>.from(team.memberIds)..add(user.uid);
      final updatedMemberNames = List<String>.from(team.memberNames)..add(user.name);

      await _firestoreService.updateTeam(teamId, {
        'memberIds': updatedMemberIds,
        'memberNames': updatedMemberNames,
      });

      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = team.copyWith(
          memberIds: updatedMemberIds,
          memberNames: updatedMemberNames,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إضافة العضو: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== إزالة عضو من المشروع =====
  Future<bool> removeMember(String teamId, String memberId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final team = await _firestoreService.getTeam(teamId);
      if (team == null) {
        _errorMessage = 'المشروع غير موجود';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (team.leaderId == memberId) {
        _errorMessage = 'لا يمكن إزالة قائد المشروع';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedMemberIds = List<String>.from(team.memberIds)..remove(memberId);
      final index = team.memberIds.indexOf(memberId);
      final updatedMemberNames = List<String>.from(team.memberNames);
      if (index != -1) {
        updatedMemberNames.removeAt(index);
      }

      await _firestoreService.updateTeam(teamId, {
        'memberIds': updatedMemberIds,
        'memberNames': updatedMemberNames,
      });

      final teamIndex = _teams.indexWhere((t) => t.id == teamId);
      if (teamIndex != -1) {
        _teams[teamIndex] = team.copyWith(
          memberIds: updatedMemberIds,
          memberNames: updatedMemberNames,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إزالة العضو: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== تحديث المشروع =====
  Future<bool> updateTeam({
    required String teamId,
    String? projectName,
    String? description,
    DateTime? deadline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {};
      if (projectName != null) data['projectName'] = projectName;
      if (description != null) data['description'] = description;
      if (deadline != null) data['deadline'] = deadline;

      if (data.isNotEmpty) {
        await _firestoreService.updateTeam(teamId, data);
      }

      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams[index] = _teams[index].copyWith(
          projectName: projectName,
          description: description,
          deadline: deadline,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحديث المشروع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== أرشفة مشروع =====
  Future<bool> archiveTeam(String teamId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateTeam(teamId, {
        'status': 'archived',
      });

      final index = _teams.indexWhere((t) => t.id == teamId);
      if (index != -1) {
        _teams.removeAt(index);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في أرشفة المشروع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== استعادة مشروع مؤرشف =====
  Future<bool> unarchiveTeam(String teamId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateTeam(teamId, {
        'status': 'active',
      });
      await loadTeams();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في استعادة المشروع: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== دوال مساعدة =====
  List<TeamModel> get activeTeams {
    return _teams.where((team) => team.status == 'active').toList();
  }

  List<TeamModel> get archivedTeams {
    return _teams.where((team) => team.status == 'archived').toList();
  }

  List<TeamModel> get ledTeams {
    final user = _authService.currentUser;
    if (user == null) return [];
    return _teams.where((team) => team.leaderId == user.uid).toList();
  }

  Future<Map<String, int>> getTaskCountsByLane(String teamId) async {
    try {
      final tasks = await _firestoreService.getTasksForTeam(teamId).first;
      final counts = {
        'todo': 0,
        'inProgress': 0,
        'review': 0,
        'done': 0,
      };
      for (var doc in tasks.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final laneId = data['laneId'] ?? 'todo';
        if (counts.containsKey(laneId)) {
          counts[laneId] = counts[laneId]! + 1;
        }
      }
      return counts;
    } catch (e) {
      return {'todo': 0, 'inProgress': 0, 'review': 0, 'done': 0};
    }
  }

  Future<double> getTeamProgress(String teamId) async {
    try {
      final tasks = await _firestoreService.getTasksForTeam(teamId).first;
      if (tasks.docs.isEmpty) return 0.0;
      final completed = tasks.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['laneId'] == 'done';
      }).length;
      return completed / tasks.docs.length;
    } catch (e) {
      return 0.0;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}