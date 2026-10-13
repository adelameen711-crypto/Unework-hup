import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class TeamCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback? onTap;
  final VoidCallback? onViewKanban;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.onViewKanban,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      team.projectName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team.projectName, style: AppTextStyles.headline3),
                        Text(team.description, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: team.status == 'active' ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      team.status == 'active' ? 'نشط' : 'مكتمل',
                      style: TextStyle(
                        fontSize: 10,
                        color: team.status == 'active' ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${team.memberIds.length} أعضاء', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: team.progress,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              if (onViewKanban != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: onViewKanban,
                    icon: const Icon(Icons.view_kanban, size: 16),
                    label: const Text('فتح اللوحة'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}