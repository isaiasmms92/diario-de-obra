import 'package:flutter/material.dart';

class NovoRegistroScreen extends StatelessWidget {
  final String obraId;

  const NovoRegistroScreen({Key? key, required this.obraId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo Registro Diário"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Descrição",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Salvar registro no Firestore
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
