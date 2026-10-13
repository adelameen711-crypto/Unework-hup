import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/teams_screen.dart';
import '../screens/kanban_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/certificate_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/reset-password';

        // إذا كان مسجلاً وحاول الذهاب لشاشات الدخول → حوله للرئيسية
        if (isAuthenticated && isLoginRoute) {
          return '/home';
        }
        // إذا لم يكن مسجلاً وحاول الذهاب لشاشة محمية → حوله لتسجيل الدخول
        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }
        return null;
      },
      routes: [
        // ===== شاشات المصادقة (بدون حماية) =====
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => const ResetPasswordScreen(),
        ),

        // ===== الشاشات الرئيسية (محمية) =====
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/teams',
          builder: (context, state) => const TeamsScreen(),
        ),
        GoRoute(
          path: '/kanban/:teamId',
          builder: (context, state) {
            final teamId = state.pathParameters['teamId'] ?? '';
            return KanbanScreen(teamId: teamId);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/certificates',
          builder: (context, state) => const CertificateScreen(),
        ),
      ],
    );
  }
}