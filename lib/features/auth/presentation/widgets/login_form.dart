import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final Function(String email, String password) onEmailLogin;

  const LoginForm({
    Key? key,
    required this.isLoading,
    this.errorMessage,
    required this.onEmailLogin,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Por favor, insira um email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira sua senha';
              }
              if (value.length < 6) {
                return 'A senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      // Implementar recuperação de senha
                    },
              child: const Text('Esqueceu a senha?'),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: widget.isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onEmailLogin(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Entrar'),
            ),
          ),
        ],
      ),
    );
  }
}
