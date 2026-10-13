// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unework_hub/models/task_model.dart';
import 'package:unework_hub/providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../widgets/task_card.dart';
import '../widgets/app_scaffold.dart';

class KanbanScreen extends StatefulWidget {
  final String teamId;

  const KanbanScreen({super.key, required this.teamId});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  // Controllers for add task dialog
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedLane = 'todo';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks(widget.teamId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return AppScaffold(
      currentIndex: 2,
      title: 'لوحة كانبان',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddTaskDialog(context),
          tooltip: 'إضافة مهمة جديدة',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            Provider.of<TaskProvider>(context, listen: false)
                .loadTasks(widget.teamId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث المهام'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          tooltip: 'تحديث',
        ),
      ],
      child: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildColumn('📌 To Do', 'todo', Colors.grey),
                  const SizedBox(width: 8),
                  _buildColumn('🔧 In Progress', 'inProgress', Colors.blue),
                  const SizedBox(width: 8),
                  _buildColumn('👀 Review', 'review', Colors.orange),
                  const SizedBox(width: 8),
                  _buildColumn('✅ Done', 'done', Colors.green),
                ],
              ),
            ),
    );
  }

  Widget _buildColumn(String title, String laneId, Color color) {
    final tasks = Provider.of<TaskProvider>(context).getTasksByLane(laneId);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, color: color, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () {
                      _showTaskDetailsDialog(context, task);
                    },
                    onStatusChange: () {
                      _moveTaskToNextLane(task);
                    },
                    onDelete: () {
                      _deleteTask(task);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _selectedLane = laneId;
                  _showAddTaskDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  foregroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('➕ إضافة مهمة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, {String? laneId}) {
    _titleController.clear();
    _descController.clear();
    _formKey.currentState?.reset();
    
    if (laneId != null) {
      _selectedLane = laneId;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_task, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('إضافة مهمة جديدة'),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة',
                  hintText: 'أدخل عنوان المهمة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال عنوان المهمة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'وصف المهمة',
                  hintText: 'وصف تفصيلي للمهمة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedLane,
                decoration: const InputDecoration(
                  labelText: 'المسار',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.arrow_forward),
                ),
                items: const [
                  DropdownMenuItem(value: 'todo', child: Text('📌 To Do')),
                  DropdownMenuItem(value: 'inProgress', child: Text('🔧 In Progress')),
                  DropdownMenuItem(value: 'review', child: Text('👀 Review')),
                  DropdownMenuItem(value: 'done', child: Text('✅ Done')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _selectedLane = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                await taskProvider.addTask(
                  teamId: widget.teamId,
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  assignedTo: authProvider.user?.uid ?? '',
                  assignedToName: authProvider.user?.displayName ?? '',
                  laneId: _selectedLane,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إضافة المهمة ✅'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('إضافة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text('الأولوية: ${task.priority}'),
                  backgroundColor: task.priorityColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: task.priorityColor),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(task.laneTitle),
                  backgroundColor: task.laneColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: task.laneColor),
                ),
              ],
            ),
            if (task.dueDate != null) ...[
              const SizedBox(height: 8),
              Text('📅 التاريخ: ${task.dueDate!.year}/${task.dueDate!.month}/${task.dueDate!.day}'),
            ],
            if (task.history.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('سجل التغييرات:', style: TextStyle(fontWeight: FontWeight.w500)),
              ...task.history.map((h) => Text('• تم النقل إلى "${h.laneId}"')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          if (task.laneId != 'done')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _moveTaskToNextLane(task);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('تقدم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _moveTaskToNextLane(TaskModel task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final laneOrder = ['todo', 'inProgress', 'review', 'done'];
    final currentIndex = laneOrder.indexOf(task.laneId);

    if (currentIndex < laneOrder.length - 1) {
      final nextLane = laneOrder[currentIndex + 1];
      taskProvider.updateTaskLane(widget.teamId, task.id, nextLane);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم نقل المهمة إلى ${task.laneTitle}'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المهمة'),
        content: Text('هل أنت متأكد من حذف مهمة "${task.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.deleteTask(widget.teamId, task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المهمة 🗑️'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}