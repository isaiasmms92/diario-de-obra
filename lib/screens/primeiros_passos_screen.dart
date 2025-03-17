import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrimeirosPassosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Primeiros passos',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            context.go('/home'); // Volta para a tela inicial ao fechar
          },
        ),
        elevation: 0, // Remove sombra para um design limpo
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estamos quase lá!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Finalize o seu cadastro para começar a utilizar todos os recursos.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            _buildPassoItem(
              icon: Icons.home,
              title: 'Faça o cadastro de suas obras no sistema.',
            ),
            SizedBox(height: 16),
            _buildPassoItem(
              icon: Icons.receipt,
              title:
                  'Para cada dia de trabalho na obra, crie um Relatório Diário de Obra (RDO).',
            ),
            SizedBox(height: 16),
            _buildPassoItem(
              icon: Icons.check_circle_outline,
              title:
                  'Acompanhe e analise o dia a dia da obra com base nas informações inseridas no Relatório Diário de Obra.',
            ),
            Spacer(), // Empurra o botão "Avançar" para o final da tela
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.go(
                      '/add-obra'); // Navega para a tela inicial após avançar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize:
                      Size(double.infinity, 50), // Botão com largura total
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Avançar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar cada item de passo com ícone e texto
  Widget _buildPassoItem({required IconData icon, required String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
