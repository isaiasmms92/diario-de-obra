// features/obra/presentation/pages/obra_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../core/di/injection_container.dart' as di;
import '../../data/models/obra_model.dart';
import '../../domain/entities/obra.dart';
import '../../domain/usecases/get_obra_by_id_usecase.dart';

class ObraDetailPage extends StatefulWidget {
  final String? obraId;
  final ObraModel? obraModel;

  // Construtor que exige pelo menos um dos dois parâmetros
  const ObraDetailPage({
    super.key,
    this.obraId,
    this.obraModel,
  }) : assert(obraId != null || obraModel != null);

  @override
  _ObraDetailPageState createState() => _ObraDetailPageState();
}

class _ObraDetailPageState extends State<ObraDetailPage> {
  Obra? obra;
  bool isLoading = true;
  String? errorMessage;

  // Acessamos o caso de uso diretamente do container de injeção de dependências
  late final GetObraByIdUseCase getObraByIdUseCase;

  @override
  void initState() {
    super.initState();
    // Obtenção do caso de uso do container de injeção de dependências
    getObraByIdUseCase = di.sl<GetObraByIdUseCase>();

    // Se recebemos o modelo diretamente, usamos ele
    if (widget.obraModel != null) {
      setState(() {
        obra = ObraModel.calcularPrazos(widget.obraModel!);
        isLoading = false;
      });
    } else {
      // Caso contrário, carregamos pelo ID
      _loadObra();
    }
  }

  Future<void> _loadObra() async {
    if (widget.obraId == null) {
      setState(() {
        errorMessage = 'ID da obra não fornecido';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final obraCarregada = await getObraByIdUseCase(widget.obraId!);

      if (obraCarregada == null) {
        setState(() {
          errorMessage = 'Obra não encontrada';
        });
        return;
      }

      if (obraCarregada is ObraModel) {
        setState(() {
          obra = ObraModel.calcularPrazos(obraCarregada);
        });
      } else {
        setState(() {
          obra = obraCarregada;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar a obra: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title:
              Text('Detalhes da Obra', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Detalhes da Obra',
              style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadObra,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (obra == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Detalhes da Obra',
              style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text('Obra não encontrada')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          obra!.nome ?? 'Detalhes da Obra',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/'); // Volta para a tela inicial
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Ações para o menu
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da obra e contadores
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: obra!.fotoUrl != null && obra!.fotoUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(obra!.fotoUrl!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Erro ao carregar imagem: $exception');
                        },
                      )
                    : null,
                color: Colors.grey[300],
              ),
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  if (obra!.fotoUrl == null || obra!.fotoUrl!.isEmpty)
                    const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('obras')
                                .doc(obra!.id)
                                .collection('relatorios')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildCounterCard('Relatórios', '0');
                              }
                              if (snapshot.hasError) {
                                return _buildCounterCard('Relatórios', 'Erro');
                              }
                              final relatoriosCount =
                                  snapshot.data?.docs.length ?? 0;
                              return _buildCounterCard(
                                  'Relatórios', relatoriosCount.toString());
                            },
                          ),
                          _buildCounterCard('Atividades', '0'),
                          _buildCounterCard('Ocorrências', '0'),
                          _buildCounterCard('Fotos', '0'),
                          _buildCounterCard('Vídeos', '0'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Informações da obra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Obra', obra!.nome ?? ''),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow('Status', obra!.status ?? '',
                            isStatus: true),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                            'Nº do Contrato', obra!.numeroContrato ?? '',
                            isBold: true),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                            'Responsável', obra!.responsavel ?? '',
                            isBold: true),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                            'Contratante', obra!.contratante ?? '',
                            isBold: true),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                            'Data de início', obra!.dataInicio ?? '',
                            isBold: true),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                            'Previsão de término', obra!.previsaoTermino ?? '',
                            isBold: true),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          'Prazo contratual',
                          obra!.formatarPrazo(obra!.prazoContratual),
                          isBold: true,
                          fontSizeTitle: 14,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                          'Prazo decorrido',
                          obra!.formatarPrazo(obra!.prazoDecorrido),
                          isBold: true,
                          fontSizeTitle: 14,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                          'Prazo a vencer',
                          obra!.formatarPrazo(obra!.prazoVencer),
                          isBold: true,
                          fontSizeTitle: 14,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow('Endereço', obra!.endereco ?? ''),
                  const Divider(),
                  _buildInfoRow('Observação', obra!.observacao ?? ''),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.file_copy, color: Colors.blue),
                    title: const Text(
                      'Documentos da obra',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Navegar para a tela de documentos
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Visão geral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Já está na visão geral
              break;
            case 1:
              if (widget.obraModel != null) {
                // Se temos o objeto completo, navegamos com ele
                context.go('/obra_detail/relatorios', extra: widget.obraModel);
              } else if (widget.obraId != null && obra != null) {
                // Se temos o ID e a obra já foi carregada
                context.go('/obra_detail/relatorios', extra: obra);
              } else if (widget.obraId != null) {
                // Se temos apenas o ID e a obra ainda não foi carregada
                context.go('/obra/${widget.obraId}/relatorios');
              } else {
                // Caso nenhuma informação esteja disponível, mostramos um erro
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Não foi possível acessar os relatórios: informações da obra não disponíveis')),
                );
              }
              break;
            case 2:
              // Navegar para o menu da obra
              break;
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildCounterCard(String title, String count) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: 60,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.black,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isBold = true,
    double fontSizeTitle = 16,
    double fontSizeSubTitle = 14,
  }) {
    Color textColor = isStatus ? _getStatusColor(value) : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSizeTitle,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSizeSubTitle,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'não iniciada':
        return Colors.red;
      case 'paralisada':
        return Colors.yellow;
      case 'em andamento':
        return Colors.blue;
      case 'concluída':
        return Colors.green;
      default:
        return Colors.black87;
    }
  }
}
