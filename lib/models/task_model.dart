import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String teamId;
  final String title;
  final String description;
  final String assignedTo;
  final String assignedToName;
  final String laneId;
  final int position;
  final int priority;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final String? prUrl;
  final int? prNumber;
  final String? prStatus;
  final List<ColumnHistory> history;

  TaskModel({
    required this.id,
    required this.teamId,
    required this.title,
    required this.description,
    required this.assignedTo,
    this.assignedToName = '',
    this.laneId = 'todo',
    this.position = 0,
    this.priority = 2,
    this.dueDate,
    this.createdAt,
    this.prUrl,
    this.prNumber,
    this.prStatus,
    this.history = const [],
  });

  factory TaskModel.fromMap(String id, Map<String, dynamic> data) {
    return TaskModel(
      id: id,
      teamId: data['teamId'] ?? '',
      title: data['title'] ?? 'مهمة بدون عنوان',
      description: data['description'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      assignedToName: data['assignedToName'] ?? '',
      laneId: data['laneId'] ?? 'todo',
      position: data['position'] ?? 0,
      priority: data['priority'] ?? 2,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      prUrl: data['prUrl'],
      prNumber: data['prNumber'],
      prStatus: data['prStatus'],
      history: (data['history'] as List?)
          ?.map((e) => ColumnHistory.fromMap(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'laneId': laneId,
      'position': position,
      'priority': priority,
      'dueDate': dueDate,
      'createdAt': FieldValue.serverTimestamp(),
      'prUrl': prUrl,
      'prNumber': prNumber,
      'prStatus': prStatus,
      'history': history.map((e) => e.toMap()).toList(),
    };
  }

  // ============================================================
  // ✅ copyWith
  // ============================================================
  TaskModel copyWith({
    String? id,
    String? teamId,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedToName,
    String? laneId,
    int? position,
    int? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    String? prUrl,
    int? prNumber,
    String? prStatus,
    List<ColumnHistory>? history,
  }) {
    return TaskModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      laneId: laneId ?? this.laneId,
      position: position ?? this.position,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      prUrl: prUrl ?? this.prUrl,
      prNumber: prNumber ?? this.prNumber,
      prStatus: prStatus ?? this.prStatus,
      history: history ?? this.history,
    );
  }

  // ============================================================
  // ✅ Getters
  // ============================================================

  bool get isOverdue {
    if (laneId == 'done') return false;
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isCompleted => laneId == 'done';

  String get laneTitle {
    switch (laneId) {
      case 'todo': return '📌 مهام جديدة';
      case 'inProgress': return '🔧 قيد التنفيذ';
      case 'review': return '👀 مراجعة';
      case 'done': return '✅ مكتملة';
      default: return laneId;
    }
  }

  // ✅ لون العمود
  Color get laneColor {
    switch (laneId) {
      case 'todo': return Colors.grey;
      case 'inProgress': return Colors.blue;
      case 'review': return Colors.orange;
      case 'done': return Colors.green;
      default: return Colors.grey;
    }
  }

  // ✅ أيقونة العمود
  IconData get laneIcon {
    switch (laneId) {
      case 'todo': return Icons.circle_outlined;
      case 'inProgress': return Icons.play_circle_outline;
      case 'review': return Icons.remove_red_eye_outlined;
      case 'done': return Icons.check_circle_outline;
      default: return Icons.circle_outlined;
    }
  }

  // ✅ لون الأولوية
  Color get priorityColor {
    switch (priority) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }

  // ✅ نص الأولوية
  String get priorityText {
    switch (priority) {
      case 1: return 'منخفضة';
      case 2: return 'متوسطة';
      case 3: return 'مهمة';
      case 4: return 'عالية';
      case 5: return 'حرجة';
      default: return 'غير محددة';
    }
  }
}

// ============================================================
// ColumnHistory
// ============================================================

class ColumnHistory {
  final String laneId;
  final DateTime? changedAt;

  ColumnHistory({required this.laneId, this.changedAt});

  factory ColumnHistory.fromMap(Map<String, dynamic> data) {
    return ColumnHistory(
      laneId: data['laneId'] ?? '',
      changedAt: (data['changedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'laneId': laneId,
      'changedAt': FieldValue.serverTimestamp(),
    };
  }
}