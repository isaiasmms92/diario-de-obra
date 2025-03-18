// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../features/obra/data/models/obra_model.dart';
// import '../features/relatorio/data/models/relatorio_model.dart';

// class ViewRelatorioScreen extends StatelessWidget {
//   final RelatorioModel relatorio;
//   final ObraModel obra; // Agora recebemos a obra opcionalmente

//   const ViewRelatorioScreen(
//       {Key? key, required this.relatorio, required this.obra})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: Text(
//           '${relatorio.data.day}/${relatorio.data.month}/${relatorio.data.year}',
//           style: const TextStyle(color: Colors.white, fontSize: 20),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             // Ao voltar, passamos a obra de volta, se ela existir
//             context.go('/obra_detail/relatorios', extra: obra);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Título "Detalhes do relatório" e botão "Preenchendo Relatório"
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Detalhes do relatório',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orange,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 35,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Lógica para editar o relatório (pode redirecionar para edit-relatorio)
//                       context.go('/obra_detail/edit-relatorio',
//                           extra: {'relatorio': relatorio, 'obra': obra});
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                     child: const Text('Preenchendo Relatório'),
//                   ),
//                 ),
//               ],
//             ),
//             Divider(),

//             // Seção "Relatório Diário de Obra (RDO)"
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: const Text(
//                   'Relatório Diário de Obra (RDO)',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             Divider(),

//             // Detalhes do relatório em formato de tabela
//             _buildDetailRow('Data',
//                 '${relatorio.data.day}/${relatorio.data.month}/${relatorio.data.year}'),
//             Divider(),
//             // Utilizamos obra diretamente se não for null, caso contrário, buscamos no Firestore
//             obra != null
//                 ? _buildObraDetails(obra!)
//                 : FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance
//                         .collection('obras')
//                         .doc(relatorio.obraId)
//                         .get(),
//                     builder: (context, obraSnapshot) {
//                       if (obraSnapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       }
//                       if (obraSnapshot.hasError || !obraSnapshot.hasData) {
//                         return const Text('Erro ao carregar dados da obra');
//                       }

//                       final obra = ObraModel.fromMap(
//                           obraSnapshot.data!.data() as Map<String, dynamic>,
//                           obraSnapshot.data!.id);

//                       return _buildObraDetails(obra);
//                     },
//                   ),
//             Divider(),
//             // Condição climática
//             const Text(
//               'Condição climática',
//               style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange),
//             ),
//             const SizedBox(height: 8),
//             Builder(
//               builder: (context) {
//                 // Verifica e exibe apenas os períodos com selecionado: true para "Condição climática"
//                 final condicaoClimatica =
//                     relatorio.content['Condição climática'] as List<dynamic>? ??
//                         [];
//                 final clima = condicaoClimatica.isNotEmpty &&
//                         condicaoClimatica[0] is Map<String, dynamic>
//                     ? condicaoClimatica[0] as Map<String, dynamic>
//                     : {};

//                 List<Widget> weatherRows = [];

//                 // Adiciona Manhã se selecionado for true
//                 if (clima['Manhã']?['selecionado'] == true) {
//                   weatherRows.add(
//                     Expanded(
//                       child: _buildWeatherRow(
//                         'Manhã',
//                         clima['Manhã']?['tempo'] as String? ?? 'Nublado',
//                         clima['Manhã']?['condicao'] as String? ??
//                             'Impraticável',
//                       ),
//                     ),
//                   );
//                 }
//                 if (clima['Tarde']?['selecionado'] == true) {
//                   weatherRows.add(
//                     Expanded(
//                       child: _buildWeatherRow(
//                         'Tarde',
//                         clima['Tarde']?['tempo'] as String? ?? 'Chuvoso',
//                         clima['Tarde']?['condicao'] as String? ?? 'Praticável',
//                       ),
//                     ),
//                   );
//                 }
//                 if (clima['Noite']?['selecionado'] == true) {
//                   weatherRows.add(
//                     Expanded(
//                       child: _buildWeatherRow(
//                         'Noite',
//                         clima['Noite']?['tempo'] as String? ?? 'Claro',
//                         clima['Noite']?['condicao'] as String? ?? 'Praticável',
//                       ),
//                     ),
//                   );
//                 }

//                 if (weatherRows.isEmpty) {
//                   return const Padding(
//                     padding: EdgeInsets.symmetric(vertical: 16.0),
//                     child: Text(
//                       'Nenhuma condição climática selecionada',
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   );
//                 }

//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: weatherRows,
//                 );
//               },
//             ),
//             const SizedBox(height: 16),

//             const SizedBox(height: 16),

//             // Seções do relatório (Mão de obra, Equipamentos, etc.)
//             if (relatorio.sections.contains('Mão de obra'))
//               _buildSection('Mão de obra (0)'),
//             if (relatorio.sections.contains('Equipamentos'))
//               _buildSection('Equipamentos (0)'),
//             if (relatorio.sections.contains('Atividades'))
//               _buildSection('Atividades (0)'),
//             if (relatorio.sections.contains('Ocorrências'))
//               _buildSection('Ocorrências (0)'),
//             if (relatorio.sections.contains('Comentários'))
//               _buildSection('Comentários (0)'),
//             if (relatorio.sections.contains('Fotos'))
//               _buildSection('Fotos (0)'),
//             if (relatorio.sections.contains('Vídeos'))
//               _buildSection('Vídeos (0)'),
//             if (relatorio.sections.contains('Anexos'))
//               _buildSection('Anexos (0)'),

//             const SizedBox(height: 16),

//             // Assinatura manual
//             const Text(
//               'Assinatura manual',
//               style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               padding: const EdgeInsets.all(8.0),
//               child: const Text(
//                 'Assinatura',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Informações adicionais (criado por, última modificação)
//             Container(
//               padding: const EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     'Criado por: Lucas (19/02/2025 20:58)',
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   Text(
//                     'Última modificação: Lucas (19/02/2025 20:58)',
//                     style: TextStyle(fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Botão "Anterior" com data
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 OutlinedButton(
//                   onPressed: () {
//                     // // Lógica para navegar para o relatório anterior (ajuste conforme necessário)
//                     // context.go('/obra_detail/view-relatorio',
//                     //     extra: {'relatorio': relatorio});
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.grey),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text('Anterior 19/02/2025'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Método auxiliar para criar linhas de detalhes do relatório
//   Widget _buildDetailRow(String label, String value,
//       {bool isStatus = false,
//       bool isBold = true,
//       double fontSizeTitle = 16,
//       double fontSizeSubTitle = 14}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: fontSizeTitle,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: fontSizeSubTitle,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Método auxiliar para criar seções do relatório
//   Widget _buildSection(String title) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       margin: const EdgeInsets.only(bottom: 8.0),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//       ),
//       child: Row(
//         children: [
//           Column(
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(fontSize: 16, color: Colors.orange),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Método auxiliar para criar condições climáticas
//   Widget _buildWeatherCondition(
//       String period, IconData icon, String weather, String condition) {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Text(period, style: const TextStyle(fontSize: 14)),
//           Icon(icon, size: 24, color: Colors.black),
//           Text(weather, style: const TextStyle(fontSize: 14)),
//           Text(condition, style: const TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   // Método auxiliar para obter o dia da semana com base na data
//   String _getDayOfWeek(DateTime date) {
//     switch (date.weekday) {
//       case 1:
//         return 'Segunda-Feira';
//       case 2:
//         return 'Terça-Feira';
//       case 3:
//         return 'Quarta-Feira';
//       case 4:
//         return 'Quinta-Feira';
//       case 5:
//         return 'Sexta-Feira';
//       case 6:
//         return 'Sábado';
//       case 7:
//         return 'Domingo';
//       default:
//         return 'Não informado';
//     }
//   }

//   Widget _buildObraDetails(ObraModel obra) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Row(children: [
//           Expanded(
//             child:
//                 _buildDetailRow('Dia da semana', _getDayOfWeek(relatorio.data)),
//           ),
//           Expanded(
//             child: _buildDetailRow(
//                 'Nº do contrato', obra.numeroContrato ?? 'Não informado'),
//           ),
//         ]),
//         Divider(),
//         Row(children: [
//           Expanded(
//             child: _buildDetailRow(
//                 'Responsável', obra.responsavel ?? 'Não informado'),
//           ),
//           Expanded(
//             child: _buildDetailRow(
//                 'Contratante', obra.contratante ?? 'Não informado'),
//           ),
//         ]),
//         Divider(),
//         Row(children: [
//           _buildDetailRow('Obra', obra.nome ?? 'Não informado'),
//         ]),
//         Divider(),
//         Row(children: [
//           _buildDetailRow('Endereço', obra.endereco ?? 'Não informado'),
//         ]),
//         Divider(),
//         // Prazo contratual, decorrido e a vencer (exemplo fixo, ajuste conforme dados reais)
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _buildDetailRow(
//                 'Prazo contratual', obra.prazoContratual.toString() + ' dias',
//                 fontSizeTitle: 14),
//             _buildDetailRow(
//                 'Prazo decorrido', obra.prazoDecorrido.toString() + ' dias',
//                 fontSizeTitle: 14),
//             _buildDetailRow(
//                 'Prazo a vencer', obra.prazoVencer.toString() + ' dias',
//                 fontSizeTitle: 14),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildWeatherRow(String period, String weather, String condition) {
//     return Container(
//       margin: const EdgeInsets.only(right: 4, left: 4),
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Text(period, style: const TextStyle(fontSize: 14)),
//           Icon(Icons.wb_sunny, size: 24, color: Colors.black),
//           Text(weather, style: const TextStyle(fontSize: 14)),
//           Text(condition, style: const TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }
// }
