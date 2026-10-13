import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String id;
  final String projectName;
  final String description;
  final String leaderId;
  final List<String> memberIds;
  final List<String> memberNames;
  final DateTime? deadline;
  final String status;
  final String? repoName;
  final String? repoUrl;
  final DateTime? createdAt;
  final Map<String, String> tasks;  // ✅ إضافة: taskId -> status

  TeamModel({
    required this.id,
    required this.projectName,
    required this.description,
    required this.leaderId,
    this.memberIds = const [],
    this.memberNames = const [],
    this.deadline,
    this.status = 'active',
    this.repoName,
    this.repoUrl,
    this.createdAt,
    this.tasks = const {},  // ✅ إضافة
  });

  factory TeamModel.fromMap(String id, Map<String, dynamic> data) {
    return TeamModel(
      id: id,
      projectName: data['projectName'] ?? 'مشروع بدون اسم',
      description: data['description'] ?? '',
      leaderId: data['leaderId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      memberNames: List<String>.from(data['memberNames'] ?? []),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'active',
      repoName: data['repoName'],
      repoUrl: data['repoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      tasks: Map<String, String>.from(data['tasks'] ?? {}),  // ✅ إضافة
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectName': projectName,
      'description': description,
      'leaderId': leaderId,
      'memberIds': memberIds,
      'memberNames': memberNames,
      'deadline': deadline,
      'status': status,
      'repoName': repoName,
      'repoUrl': repoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'tasks': tasks,  // ✅ إضافة
    };
  }

  // ============================================================
  // ✅ دالة copyWith (المطلوبة في TeamProvider)
  // ============================================================
  TeamModel copyWith({
    String? id,
    String? projectName,
    String? description,
    String? leaderId,
    List<String>? memberIds,
    List<String>? memberNames,
    DateTime? deadline,
    String? status,
    String? repoName,
    String? repoUrl,
    DateTime? createdAt,
    Map<String, String>? tasks,
  }) {
    return TeamModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      leaderId: leaderId ?? this.leaderId,
      memberIds: memberIds ?? this.memberIds,
      memberNames: memberNames ?? this.memberNames,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      repoName: repoName ?? this.repoName,
      repoUrl: repoUrl ?? this.repoUrl,
      createdAt: createdAt ?? this.createdAt,
      tasks: tasks ?? this.tasks,
    );
  }

  // ============================================================
  // دوال مساعدة
  // ============================================================

  // ✅ حساب نسبة التقدم من المهام
  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.values.where((status) => status == 'completed').length;
    return completed / tasks.length;
  }

  // ✅ عدد المهام المكتملة
  int get completedTasks {
    return tasks.values.where((status) => status == 'completed').length;
  }

  // ✅ عدد المهام الكلي
  int get totalTasks => tasks.length;

  // ✅ هل المستخدم هو القائد؟
  bool isLeader(String uid) => leaderId == uid;

  // ✅ هل المستخدم عضو في الفريق؟
  bool isMember(String uid) => memberIds.contains(uid);

  // ✅ عدد الأعضاء
  int get memberCount => memberIds.length;

  // ✅ هل المشروع نشط؟
  bool get isActive => status == 'active';

  // ✅ هل المشروع مؤرشف؟
  bool get isArchived => status == 'archived';

  // ✅ اسم المشروع مختصر
  String get shortName {
    if (projectName.length <= 20) return projectName;
    return '${projectName.substring(0, 20)}...';
  }

  // ✅ تحويل إلى Map مع بيانات إضافية
  Map<String, dynamic> toMapWithExtra() {
    return {
      ...toMap(),
      'memberCount': memberCount,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'isActive': isActive,
    };
  }
}