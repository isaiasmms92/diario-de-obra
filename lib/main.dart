import 'package:app_diario_obra/core/di/injection_container.dart' as di;
import 'package:app_diario_obra/features/obra/presentation/controllers/obra_controller.dart';
import 'package:app_diario_obra/features/relatorio/presentation/controllers/relatorio_editor_controller.dart';
import 'package:app_diario_obra/router.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/relatorio/presentation/controllers/relatorio_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    // Para desenvolvimento, você pode usar o provedor de depuração
    // Em produção, use webRecaptcha ou playIntegrity/appAttest
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // Inicializa o container de injeção de dependências
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<ObraController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<RelatorioController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<EditRelatorioController>(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Obtenha a instância de AuthController da injeção de dependência
  final authController = di.sl<AuthController>();
  late final appRouter = AppRouter(authController: authController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.router,
      title: 'Diário de Obra',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
