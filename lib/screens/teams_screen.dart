import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../providers/team_provider.dart';
import '../models/team_model.dart';
import '../widgets/app_scaffold.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  // Controllers for create team dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).loadTeams();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);

    return AppScaffold(
      currentIndex: 1,
      title: 'المشاريع',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showCreateTeamDialog(context),
          tooltip: 'إنشاء مشروع جديد',
        ),
      ],
      child: teamProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : teamProvider.teams.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: teamProvider.teams.length,
                  itemBuilder: (context, index) {
                    final team = teamProvider.teams[index];
                    return _buildTeamCard(context, team);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: AppColors.textLight),
          SizedBox(height: 16),
          Text('لا توجد مشاريع', style: AppTextStyles.headline2),
          SizedBox(height: 8),
          Text('اضغط على زر + في الأعلى لإنشاء مشروع جديد', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, TeamModel team) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(team.projectName, style: AppTextStyles.headline3),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(team.description, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${team.memberIds.length} أعضاء', style: AppTextStyles.bodySmall),
                const SizedBox(width: 16),
                Icon(Icons.task, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${team.tasks.length} مهام', style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: team.progress,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            context.go('/kanban/${team.id}');
          },
        ),
        onTap: () {
          context.go('/kanban/${team.id}');
        },
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    _nameController.clear();
    _descController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء مشروع جديد'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المشروع',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المشروع';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'وصف المشروع',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال وصف المشروع';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final teamProvider = Provider.of<TeamProvider>(context, listen: false);
                final success = await teamProvider.createTeam(
                  projectName: _nameController.text,
                  description: _descController.text,
                );
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إنشاء المشروع بنجاح ✅')),
                  );
                }
              }
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }
}