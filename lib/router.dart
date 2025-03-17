import 'package:app_diario_obra/features/obra/data/models/obra_model.dart';
import 'package:app_diario_obra/features/relatorio/data/models/relatorio_model.dart';
import 'package:app_diario_obra/features/obra/presentation/views/add_obra_page.dart';
import 'package:app_diario_obra/screens/add_relatorio_screen.dart';
import 'package:app_diario_obra/features/obra/presentation/views/obra_detail_page.dart';
import 'package:app_diario_obra/screens/primeiros_passos_screen.dart';
import 'package:app_diario_obra/features/relatorio/presentation/views/relatorios_page.dart';
import 'package:app_diario_obra/screens/select_mao_de_obra_screen.dart';
import 'package:app_diario_obra/features/relatorio/presentation/views/view_relatorio_page.dart';
import 'package:app_diario_obra/screens/edit_relatorio_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/views/login_page.dart';
import 'features/auth/presentation/views/register_page.dart';
import 'features/obra/presentation/views/obras_page.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

// Crie uma classe para encapsular o router e a lógica de redirecionamento
class AppRouter {
  final AuthController authController;

  AppRouter({required this.authController});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/obra_detail/add-relatorio',
        builder: (context, state) {
          final obra = state.extra as ObraModel;
          return AddRelatorioScreen(obra: obra);
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const ObrasPage(),
      ),
      GoRoute(
        path: '/primeiros-passos',
        builder: (context, state) => PrimeirosPassosScreen(),
      ),
      GoRoute(
        path: '/add-obra',
        builder: (context, state) {
          return const AddObraPage();
        },
      ),
      GoRoute(
        path: '/obra_detail',
        builder: (context, state) {
          final obra = state.extra as ObraModel;
          return ObraDetailPage(obraModel: obra);
        },
        routes: [
          // Sub-rota para relatórios
          GoRoute(
            path: 'relatorios',
            pageBuilder: (context, state) {
              final obra = state.extra as ObraModel?;
              return CustomTransitionPage(
                key: state.pageKey,
                child: RelatoriosPage(obra: obra),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
          path: '/obra/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ObraDetailPage(obraId: id);
          },
          routes: [
            // Sub-rota para relatórios
            GoRoute(
                path: 'relatorios',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CustomTransitionPage(
                      key: state.pageKey,
                      child: RelatoriosPage(obraId: id),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      });
                })
          ]),
      GoRoute(
        path: '/obra_detail/view-relatorio',
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final Map<String, dynamic> args =
                state.extra as Map<String, dynamic>;
            final relatorio = args['relatorio'] as RelatorioModel;
            final obra = args['obra'] as ObraModel;
            return ViewRelatorioPage(
              relatorio: relatorio,
              obra: obra,
            );
          } else {
            throw Exception(
                'Dados passados para ViewRelatorioScreen estão no formato incorreto.');
          }
        },
      ),
      GoRoute(
        path: '/obra_detail/edit-relatorio',
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final Map<String, dynamic> args =
                state.extra as Map<String, dynamic>;
            final relatorio = args['relatorio'] as RelatorioModel;
            final obra = args['obra'] as ObraModel;
            return EditRelatorioScreen(relatorio: relatorio, obra: obra);
          } else {
            throw Exception(
                'Dados passados para EditRelatorioScreen estão no formato incorreto.');
          }
        },
      ),
      GoRoute(
        path: '/select-mao-de-obra',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SelectMaoDeObraScreen(
            selectedItems: extra['selectedItems'] as List<String>? ?? [],
            relatorioId: extra['relatorioId'] as String,
            obraId: extra['obraId'] as String,
          );
        },
      ),
    ],
    // Em versões mais recentes do GoRouter, a assinatura do redirect mudou
    redirect: (BuildContext context, GoRouterState state) {
      // Verifica o estado de autenticação
      final isAuthenticated = authController.isAuthenticated;

      // Verifica as rotas atuais - gorouter usa uri.path agora em vez de location
      final isLoginRoute = state.uri.path == '/login';
      final isRegisterRoute = state.uri.path == '/register';

      // Se não estiver autenticado e não estiver indo para login ou registro, redireciona para login
      if (!isAuthenticated && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }

      // Se estiver autenticado e estiver indo para login ou registro, redireciona para a home
      if (isAuthenticated && (isLoginRoute || isRegisterRoute)) {
        return '/';
      }

      return null;
    },
    // Você pode adicionar essa propriedade para observar mudanças no estado de autenticação
    refreshListenable: authController,
  );
}
