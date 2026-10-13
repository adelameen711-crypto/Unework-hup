import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unework_hub/navigation/app_botom_nav_bar.dart';
import '../providers/auth_provider.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String title;
  final List<Widget>? actions;  // ✅ إضافة actions اختيارية

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.title,
    this.actions,  // ✅ اختياري
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions ?? [  // ✅ إذا لم يتم تمرير actions، استخدم الافتراضي
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (!authProvider.isAuthenticated) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
      ),
    );
  }
}