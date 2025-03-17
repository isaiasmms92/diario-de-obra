import 'package:flutter/material.dart';
import '../../domain/entities/relatorio.dart';

class ClimaWidget extends StatelessWidget {
  final Relatorio relatorio;

  const ClimaWidget({
    Key? key,
    required this.relatorio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtém as condições climáticas do relatório
    final condicaoClimatica =
        relatorio.content['Condição climática'] as List<dynamic>? ?? [];
    final clima = condicaoClimatica.isNotEmpty &&
            condicaoClimatica[0] is Map<String, dynamic>
        ? condicaoClimatica[0] as Map<String, dynamic>
        : {};

    List<Widget> weatherRows = [];

    // Adiciona cada período selecionado
    if (clima['Manhã']?['selecionado'] == true) {
      weatherRows.add(
        Expanded(
          child: _buildWeatherRow(
            'Manhã',
            clima['Manhã']?['tempo'] as String? ?? 'Nublado',
            clima['Manhã']?['condicao'] as String? ?? 'Impraticável',
          ),
        ),
      );
    }

    if (clima['Tarde']?['selecionado'] == true) {
      weatherRows.add(
        Expanded(
          child: _buildWeatherRow(
            'Tarde',
            clima['Tarde']?['tempo'] as String? ?? 'Chuvoso',
            clima['Tarde']?['condicao'] as String? ?? 'Praticável',
          ),
        ),
      );
    }

    if (clima['Noite']?['selecionado'] == true) {
      weatherRows.add(
        Expanded(
          child: _buildWeatherRow(
            'Noite',
            clima['Noite']?['tempo'] as String? ?? 'Claro',
            clima['Noite']?['condicao'] as String? ?? 'Praticável',
          ),
        ),
      );
    }

    if (weatherRows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Nenhuma condição climática selecionada',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weatherRows,
    );
  }

  Widget _buildWeatherRow(String period, String weather, String condition) {
    return Container(
      margin: const EdgeInsets.only(right: 4, left: 4),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(period, style: const TextStyle(fontSize: 14)),
          const Icon(Icons.wb_sunny, size: 24, color: Colors.black),
          Text(weather, style: const TextStyle(fontSize: 14)),
          Text(condition, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
