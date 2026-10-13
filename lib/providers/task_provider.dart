import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _tasks = [];
  TaskModel? _currentTask;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentTeamId = '';

  // ===== Getters =====
  List<TaskModel> get tasks => _tasks;
  TaskModel? get currentTask => _currentTask;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentTeamId => _currentTeamId;

  // ===== تحميل المهام =====
  Future<void> loadTasks(String teamId) async {
    _currentTeamId = teamId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getTasksForTeam(teamId).first;
      _tasks = snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      _sortTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحميل المهام: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== إضافة مهمة =====
  Future<bool> addTask({
    required String teamId,
    required String title,
    required String description,
    required String assignedTo,
    required String assignedToName,
    String laneId = 'todo',
    int priority = 2,
    DateTime? dueDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tasksInLane = _tasks.where((t) => t.laneId == laneId).length;

      final task = TaskModel(
        id: _firestoreService.generateId(),
        teamId: teamId,
        title: title,
        description: description,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        laneId: laneId,
        position: tasksInLane,
        priority: priority,
        dueDate: dueDate,
      );

      final taskId = await _firestoreService.addTask(teamId, task);

      final newTask = TaskModel(
        id: taskId,
        teamId: teamId,
        title: title,
        description: description,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        laneId: laneId,
        position: tasksInLane,
        priority: priority,
        dueDate: dueDate,
      );

      _tasks.add(newTask);
      _sortTasks();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إضافة المهمة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // ⭐ الميزة الأساسية لـ Kanban: نقل المهمة بين الأعمدة
  // ============================================================
  Future<bool> moveTaskBetweenLanes({
    required String teamId,
    required String taskId,
    required String fromLaneId,
    required String toLaneId,
    required int newIndex,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. تحديث في Firestore
      await _firestoreService.updateTaskLane(teamId, taskId, toLaneId);

      // 2. تحديث محلياً
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final taskToMove = _tasks[index];
        _tasks.removeAt(index);

        // تحديث المهمة بالعمود الجديد والموضع الجديد
        final updatedTask = taskToMove.copyWith(
          laneId: toLaneId,
          position: newIndex,
        );
        _tasks.add(updatedTask);

        // 3. إعادة ترتيب المواضع في كلا العمودين
        await _reorderPositions(teamId, fromLaneId);
        await _reorderPositions(teamId, toLaneId);

        _sortTasks();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في نقل المهمة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // ⭐ الميزة الأساسية لـ Kanban: إعادة ترتيب المهام داخل العمود
  // ============================================================
  Future<bool> reorderTasksWithinLane({
    required String teamId,
    required String laneId,
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      // 1. الحصول على مهام العمود
      final tasksInLane = _tasks
          .where((t) => t.laneId == laneId)
          .toList()
        ..sort((a, b) => a.position.compareTo(b.position));

      if (oldIndex < 0 || oldIndex >= tasksInLane.length) return false;
      if (newIndex < 0 || newIndex > tasksInLane.length) return false;

      // 2. إعادة الترتيب محلياً
      final task = tasksInLane.removeAt(oldIndex);
      final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
      tasksInLane.insert(insertIndex, task);

      // 3. تحديث المواضع في Firestore
      for (var i = 0; i < tasksInLane.length; i++) {
        await _firestoreService.updateTaskPosition(
          teamId,
          tasksInLane[i].id,
          i,
        );
      }

      // 4. تحديث القائمة المحلية
      for (var i = 0; i < tasksInLane.length; i++) {
        final index = _tasks.indexWhere((t) => t.id == tasksInLane[i].id);
        if (index != -1) {
          _tasks[index] = tasksInLane[i].copyWith(position: i);
        }
      }

      _sortTasks();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في إعادة ترتيب المهام: $e';
      notifyListeners();
      return false;
    }
  }

  // ===== تحديث عمود المهمة (طريقة مبسطة) =====
  Future<bool> updateTaskLane(String teamId, String taskId, String newLaneId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateTaskLane(teamId, taskId, newLaneId);

      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final oldLaneId = _tasks[index].laneId;
        final taskToMove = _tasks[index];

        _tasks.removeAt(index);

        final tasksInNewLane = _tasks.where((t) => t.laneId == newLaneId).length;
        final updatedTask = taskToMove.copyWith(
          laneId: newLaneId,
          position: tasksInNewLane,
        );
        _tasks.add(updatedTask);

        await _reorderPositions(teamId, oldLaneId);
        await _reorderPositions(teamId, newLaneId);

        _sortTasks();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحديث عمود المهمة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== تحديث ترتيب المهمة =====
  Future<bool> updateTaskPosition(String teamId, String taskId, int newPosition) async {
    try {
      await _firestoreService.updateTaskPosition(teamId, taskId, newPosition);

      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final taskToUpdate = _tasks[index];
        _tasks[index] = taskToUpdate.copyWith(position: newPosition);
        _sortTasks();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في تحديث ترتيب المهمة: $e';
      notifyListeners();
      return false;
    }
  }

  // ===== حذف مهمة =====
  Future<bool> deleteTask(String teamId, String taskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final laneId = task.laneId;

      await _firestoreService.deleteTask(teamId, taskId);

      _tasks.removeWhere((t) => t.id == taskId);

      await _reorderPositions(teamId, laneId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ في حذف المهمة: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== الحصول على مهام حسب العمود (مرتبة) =====
  List<TaskModel> getTasksByLane(String laneId) {
    return _tasks
        .where((t) => t.laneId == laneId)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  // ===== الحصول على جميع المهام مقسمة حسب الأعمدة (لـ VooKanban) =====
  Map<String, List<TaskModel>> getTasksGroupedByLane() {
    final Map<String, List<TaskModel>> result = {
      'todo': [],
      'inProgress': [],
      'review': [],
      'done': [],
    };

    for (var task in _tasks) {
      if (result.containsKey(task.laneId)) {
        result[task.laneId]!.add(task);
      }
    }

    // ترتيب كل قائمة حسب الموضع
    for (var key in result.keys) {
      result[key]!.sort((a, b) => a.position.compareTo(b.position));
    }

    return result;
  }

  // ===== إعادة ترتيب المواضع في العمود =====
  Future<void> _reorderPositions(String teamId, String laneId) async {
    final tasksInLane = _tasks
        .where((t) => t.laneId == laneId)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    for (var i = 0; i < tasksInLane.length; i++) {
      await _firestoreService.updateTaskPosition(teamId, tasksInLane[i].id, i);
    }
  }

  // ===== ترتيب المهام =====
  void _sortTasks() {
    _tasks.sort((a, b) {
      final laneOrder = {'todo': 0, 'inProgress': 1, 'review': 2, 'done': 3};
      final laneCompare = laneOrder[a.laneId]!.compareTo(laneOrder[b.laneId]!);
      if (laneCompare != 0) return laneCompare;
      return a.position.compareTo(b.position);
    });
  }

  // ===== الحصول على مهمة بواسطة ID =====
  TaskModel? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // ===== عدد المهام الكلي =====
  int get totalTasks => _tasks.length;

  // ===== عدد المهام المكتملة =====
  int get completedTasks {
    return _tasks.where((t) => t.laneId == 'done').length;
  }

  // ===== نسبة التقدم =====
  double get progress {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks / _tasks.length;
  }

  // ===== مسح رسالة الخطأ =====
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// ===== Extension لتسهيل نسخ TaskModel =====
extension TaskModelCopy on TaskModel {
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
}