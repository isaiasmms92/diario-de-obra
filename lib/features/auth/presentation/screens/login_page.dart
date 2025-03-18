import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    Future<bool> verificarConectividade() async {
      try {
        // Primeiro verifica a conectividade geral
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('Conectado à internet');

          // Em seguida, verifica o Firebase
          final firebaseResult =
              await InternetAddress.lookup('firebase.google.com');
          if (firebaseResult.isNotEmpty &&
              firebaseResult[0].rawAddress.isNotEmpty) {
            print('Conectado ao Firebase');
            return true;
          }
        }
        return false;
      } on SocketException catch (_) {
        print('Sem conexão com a internet');
        return false;
      }
    }

    Future<bool> verificarGooglePlayServices() async {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        // Verifica se o Google Play Services está disponível
        await googleSignIn.signInSilently();
        return true;
      } catch (e) {
        print('Erro no Google Play Services: $e');
        return false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'Bem-vindo',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Faça login para continuar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                LoginForm(
                  isLoading: authController.isLoading,
                  errorMessage: authController.errorMessage,
                  onEmailLogin: (email, password) async {
                    verificarConectividade();
                    final success =
                        await authController.loginWithEmail(email, password);
                    if (success && context.mounted) {
                      context.go('/');
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'OU',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.g_translate, color: Colors.red),
                  label: const Text('Entrar com Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  onPressed: authController.isLoading
                      ? null
                      : () async {
                          verificarConectividade();
                          final success =
                              await authController.loginWithGoogle();
                          if (success && context.mounted) {
                            context.go('/');
                          }
                        },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta? '),
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      child: const Text('Registre-se'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
