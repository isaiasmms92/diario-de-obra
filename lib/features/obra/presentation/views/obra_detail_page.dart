import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../core/di/injection_container.dart' as di;
import '../../data/models/obra_model.dart';
import '../../domain/entities/obra.dart';
import '../../domain/usecases/get_obra_by_id_usecase.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../features/relatorio/presentation/views/relatorios_page.dart';

class ObraDetailPage extends StatefulWidget {
  final String? obraId;
  final ObraModel? obraModel;
  final int initialTabIndex;

  // Construtor que exige pelo menos um dos dois parâmetros
  const ObraDetailPage({
    super.key,
    this.obraId,
    this.obraModel,
    this.initialTabIndex = 0,
  }) : assert(obraId != null || obraModel != null);

  @override
  _ObraDetailPageState createState() => _ObraDetailPageState();
}

class _ObraDetailPageState extends State<ObraDetailPage>
    with SingleTickerProviderStateMixin {
  Obra? obra;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Controle da aba atual
  late int _currentIndex;
  late final PageController _pageController;

  // Acessamos o caso de uso diretamente do container de injeção de dependências
  late final GetObraByIdUseCase getObraByIdUseCase;

  @override
  void initState() {
    super.initState();

    // Inicializa o índice atual com o valor fornecido
    _currentIndex = widget.initialTabIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Configuração da animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Obtenção do caso de uso do container de injeção de dependências
    getObraByIdUseCase = di.sl<GetObraByIdUseCase>();

    // Se recebemos o modelo diretamente, usamos ele
    if (widget.obraModel != null) {
      setState(() {
        obra = ObraModel.calcularPrazos(widget.obraModel!);
        isLoading = false;
      });
      _animationController.forward();
    } else {
      // Caso contrário, carregamos pelo ID
      _loadObra();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
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
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          isLoading ? 'Detalhes da Obra' : (obra?.nome ?? 'Detalhes da Obra'),
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
      body: errorMessage != null
          ? _buildErrorWidget()
          : isLoading
              ? _buildLoadingWidget()
              : FadeTransition(
                  opacity: _fadeInAnimation,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: [
                      _buildVisaoGeralWidget(),
                      _buildRelatoriosWidget(),
                      _buildMenuWidget(),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
          // Atualizamos o estado e navegamos para a página correspondente
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );

          // Atualiza a URL sem recarregar a página (opcional, caso queira manter o histórico)
          // Este bloco só seria necessário se você quiser que a URL reflita a aba atual
          // Se não for necessário, pode remover este bloco
          /*
          if (index == 1) {
            // Se estiver indo para relatórios
            if (widget.obraModel != null) {
              context.goNamed('visaoRelatorios', extra: widget.obraModel);
            } else if (widget.obraId != null) {
              context.goNamed('visaoRelatorios', params: {'id': widget.obraId!});
            }
          }
          */
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
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
    );
  }

  Widget _buildLoadingWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer de carregamento para a imagem
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Shimmer para título de informações
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    width: 200,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Shimmer para linha de informação
                _buildShimmerInfoRow(),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: _buildShimmerInfoRow()),
                    Expanded(child: _buildShimmerInfoRow()),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: _buildShimmerInfoRow()),
                    Expanded(child: _buildShimmerInfoRow()),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: _buildShimmerInfoRow()),
                    Expanded(child: _buildShimmerInfoRow()),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: _buildShimmerInfoRow()),
                    Expanded(child: _buildShimmerInfoRow()),
                    Expanded(child: _buildShimmerInfoRow()),
                  ],
                ),
                const Divider(),
                _buildShimmerInfoRow(),
                const Divider(),
                _buildShimmerInfoRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 16,
              width: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 14,
              width: 150,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para a aba Visão Geral (índice 0)
  Widget _buildVisaoGeralWidget() {
    if (obra == null) {
      return const Center(child: Text('Obra não encontrada'));
    }

    return SingleChildScrollView(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  // Na ObraDetailPage, atualize o método _buildRelatoriosWidget
  Widget _buildRelatoriosWidget() {
    if (obra == null) {
      return const Center(child: Text('Obra não encontrada'));
    }

    if (obra is ObraModel) {
      return RelatoriosPage(obra: obra as ObraModel, isEmbedded: true);
    } else if (widget.obraId != null) {
      return RelatoriosPage(obraId: widget.obraId, isEmbedded: true);
    } else {
      return const Center(
        child: Text('Não foi possível carregar os relatórios'),
      );
    }
  }

  // Widget para a aba Menu (índice 2)
  Widget _buildMenuWidget() {
    final menuItems = [
      {'icon': Icons.edit, 'title': 'Editar Obra', 'onTap': () {}},
      {'icon': Icons.description, 'title': 'Documentos', 'onTap': () {}},
      {'icon': Icons.camera_alt, 'title': 'Fotos', 'onTap': () {}},
      {'icon': Icons.videocam, 'title': 'Vídeos', 'onTap': () {}},
      {'icon': Icons.warning, 'title': 'Ocorrências', 'onTap': () {}},
      {'icon': Icons.work, 'title': 'Atividades', 'onTap': () {}},
      {'icon': Icons.people, 'title': 'Equipe', 'onTap': () {}},
      {'icon': Icons.delete, 'title': 'Excluir Obra', 'onTap': () {}},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isDeleteOption = item['title'] == 'Excluir Obra';

        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: isDeleteOption ? Colors.red : Colors.blue,
          ),
          title: Text(
            item['title'] as String,
            style: TextStyle(
              color: isDeleteOption ? Colors.red : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: item['onTap'] as Function(),
        );
      },
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
