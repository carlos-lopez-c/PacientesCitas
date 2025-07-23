import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paciente_citas_1/auth/presentation/providers/auth_provider.dart';
import 'package:paciente_citas_1/auth/presentation/screens/check_auth_status_screen.dart';
import 'package:paciente_citas_1/auth/presentation/screens/forgot_password_screen.dart';
import 'package:paciente_citas_1/auth/presentation/screens/login_screen.dart';
import 'package:paciente_citas_1/auth/presentation/screens/register_screen.dart';
import 'package:paciente_citas_1/auth/presentation/screens/verify_2fa_screen.dart';
import 'package:paciente_citas_1/config/routes/app_router_notifier.dart';
import 'package:paciente_citas_1/home/presentation/screens/home_screen.dart';
import 'package:paciente_citas_1/home/presentation/screens/registerappointment_screen.dart' show RegisterAppointment;

final goRouterProvider = Provider<GoRouter>((ref) {
  final goRouterNotifier = ref.watch(goRouterNotifierProvider);
  // Crear el router con una key global para realizar redirecciones de forma segura
  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    redirect: (context, state) {
      final isGoingTo = state.uri.path;
      final authStatus = goRouterNotifier.authStatus;

      print(
          '🔄 Router redirect - Going to: $isGoingTo, AuthStatus: $authStatus');

      if (authStatus == AuthStatus.requires2FA) {
        if (isGoingTo == '/verify-2fa') {
          print('✅ Already on verify-2fa page');
          return null;
        }
        print('🔐 Redirecting to /verify-2fa');
        return '/verify-2fa';
      }

      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/forgot-password' ||
            isGoingTo == '/register' ||
            isGoingTo == '/verify-2fa') {
          print('✅ Already on auth page');
          return null;
        }
        print('🔄 Redirecting to /login');
        return '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/splash' ||
            isGoingTo == '/forgot-password' ||
            isGoingTo == '/register' ||
            isGoingTo == '/verify-2fa') {
          print('🏠 Redirecting to /home');
          return '/home';
        }
      }

      print('✅ No redirect needed');
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
