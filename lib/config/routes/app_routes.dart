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

  // Crear el router con una key global para realizar redirecciones de forma segura
  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.notifier)),
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToVerify2FA = state.matchedLocation == '/verify-2fa';
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToHome = state.matchedLocation == '/home';
      final isGoingToRoot = state.matchedLocation == '/';
      final isGoingToForgotPassword =
          state.matchedLocation == '/forgot-password';

      // IMPORTANTE: Si estamos en la pantalla de registro o en proceso de registro, no redirigir
      if (isGoingToRegister || authState.isRegisterLoading) return null;

      // IMPORTANTE: Solo redirigir a checking si no estamos en proceso de registro
      if (authState.authStatus == AuthStatus.checking &&
          !authState.isRegisterLoading) {
        if (isGoingToSplash) return null;
        return '/splash';
      }

      // Si no está autenticado
      if (authState.authStatus == AuthStatus.notAuthenticated) {
        // Permitir las rutas de autenticación y recuperación de contraseña
        if (isGoingToLogin || isGoingToSplash || isGoingToForgotPassword)
          return null;
        return '/login';
      }

      // Si requiere 2FA
      if (authState.authStatus == AuthStatus.requires2FA) {
        if (isGoingToVerify2FA) return null;
        return '/verify-2fa';
      }

      // Si está autenticado
      if (authState.authStatus == AuthStatus.authenticated) {
        // No permitir volver a las pantallas de autenticación
        if (isGoingToLogin ||
            isGoingToVerify2FA ||
            isGoingToSplash ||
            isGoingToRoot ||
            isGoingToForgotPassword) {
          return '/home';
        }
        return null;
      }

      return null;
    },
    routes: [
      ///* Primera pantalla - verificación de autenticación
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

      ///* User Routes
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
        redirect: (context, state) => '/splash',
      ),
    ],
  );

  return router;
});

// Stream para notificar al router sobre cambios en el estado de autenticación
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(AuthNotifier authNotifier) {
    // Usamos un try-catch para evitar errores de inicialización
    try {
      _authStateListener = authNotifier.addListener((state) {
        // Solo notificamos si el objeto aún está activo
        if (!_disposed) {
          notifyListeners();
        }
      }, fireImmediately: false);
    } catch (e) {
      debugPrint('Error al configurar GoRouterRefreshStream: $e');
    }
  }

  late final void Function() _authStateListener;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    try {
      _authStateListener();
    } catch (e) {
      debugPrint('Error al liberar _authStateListener: $e');
    }
    super.dispose();
  }
}
