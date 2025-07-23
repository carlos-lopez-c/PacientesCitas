import 'package:flutter/material.dart';
import 'package:paciente_citas_1/config/constants/enviroments.dart';
import 'package:paciente_citas_1/config/firebase/firebase_options.dart';
import 'package:paciente_citas_1/config/theme/app_theme.dart';
import 'package:paciente_citas_1/notifications/presentation/providers/notification_provider.dart';
import 'config/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Environment.initEnvironment();
  await initializeDateFormatting('es', null);

  
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);
    
    // Inicializar notificaciones al iniciar la app
    ref.watch(notificationProvider);
    
    return MaterialApp.router(
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
      ],
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme().getTheme(),
    );
  }
}
