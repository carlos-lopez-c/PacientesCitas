import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fundacion_paciente_app/auth/presentation/providers/auth_provider.dart';
import 'package:fundacion_paciente_app/auth/presentation/screens/check_auth_status_screen.dart';
import 'package:fundacion_paciente_app/auth/presentation/screens/forgot_password_screen.dart';
import 'package:fundacion_paciente_app/auth/presentation/screens/login_screen.dart';
import 'package:fundacion_paciente_app/auth/presentation/screens/register_screen.dart';
import 'package:fundacion_paciente_app/auth/presentation/screens/verify_2fa_screen.dart';
import 'package:fundacion_paciente_app/config/routes/app_router_notifier.dart';
import 'package:fundacion_paciente_app/home/presentation/screens/home_screen.dart';
import 'package:fundacion_paciente_app/home/presentation/screens/registerappointment_screen.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToVerify2FA = state.matchedLocation == '/verify-2fa';
      final isGoingToHome = state.matchedLocation == '/home';

      if (authState.authStatus == AuthStatus.checking) return null;

      if (authState.authStatus == AuthStatus.notAuthenticated) {
        if (isGoingToLogin || isGoingToRegister) return null;
        return '/login';
      }

      if (authState.authStatus == AuthStatus.requires2FA) {
        if (isGoingToVerify2FA) return null;
        return '/verify-2fa';
      }

      if (authState.authStatus == AuthStatus.authenticated) {
        if (isGoingToHome) return null;
        return '/home';
      }

      return null;
    },
    routes: [
      ///* Primera pantalla
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),

      GoRoute(
          path: '/register-appointment',
          builder: (context, state) {
            return const RegisterAppointment();
          }),

      ///* Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen()),

      ///* Product Routes
      GoRoute(
        path: '/verify-2fa',
        builder: (context, state) => const Verify2FAScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
    ],
  );
});
