import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../models/entrada_diario.dart';
import '../../utils/utils.dart';

class DiarioScreen extends StatefulWidget {
  @override
  _DiarioScreenState createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;
  String _filtroAtivo = 'todos';
  bool _isLoading = true;
  
  List<EntradaDiario> entradas = [];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward();
    _carregarEntradas();
  }

  Future<void> _carregarEntradas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedEntradas = await ApiService.getDiaryEntries();
      if (!mounted) return;
      setState(() {
        entradas = fetchedEntradas;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar diário: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilters(),
          _buildStatCards(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildEntradasList(),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: _criarNovaEntrada,
          backgroundColor: Color(0xFF26C6DA),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: Icon(Icons.edit),
          label: Text(
            'Nova escrita',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'S.O.S Psicologia',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Seu Diário',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Barra de pesquisa
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Filtros de humor
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('todos', 'Todos', Icons.all_inclusive),
                _buildFilterChip('feliz', 'Feliz', Icons.mood),
                _buildFilterChip('triste', 'Triste', Icons.mood_bad),
                _buildFilterChip('ansioso', 'Ansioso', Icons.psychology),
                _buildFilterChip('calmo', 'Calmo', Icons.self_improvement),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filtro, String label, IconData icon) {
    final bool isActive = _filtroAtivo == filtro;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isActive,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[600]),
            SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (bool selected) {
          setState(() {
            _filtroAtivo = selected ? filtro : 'todos';
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Color(0xFF26C6DA),
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive ? Color(0xFF26C6DA) : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total de Entradas',
              '${entradas.length}',
              Icons.book_outlined,
              Color(0xFF4FC3F7),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Este Mês',
              '${_entradasDoMes()}',
              Icons.calendar_month,
              Color(0xFF66BB6A),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Sequência',
              '${_sequenciaAtual()} dias',
              Icons.local_fire_department,
              Color(0xFFFF7043),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icon, Color cor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: cor, size: 24),
          SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEntradasList() {
    final entradasFiltradas = _filtrarEntradas();
    
    if (entradasFiltradas.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Últimos 30 dias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: entradasFiltradas.length,
              itemBuilder: (context, index) {
                final entrada = entradasFiltradas[index];
                final isFirst = index == 0;
                final proximaEntrada = index < entradasFiltradas.length - 1
                    ? entradasFiltradas[index + 1]
                    : null;
                
                final mostrarAno = proximaEntrada?.data.year != entrada.data.year;
                final mostrarMes = proximaEntrada?.data.month != entrada.data.month ||
                                  proximaEntrada?.data.year != entrada.data.year;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirst || mostrarMes) _buildSectionHeader(entrada.data, mostrarAno),
                    _buildEntradaCard(entrada),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(DateTime data, bool mostrarAno) {
    final meses = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        mostrarAno ? '${meses[data.month]} ${data.year}' : meses[data.month],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildEntradaCard(EntradaDiario entrada) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _abrirEntrada(entrada),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: getHumorColor(entrada.humor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${entrada.data.day.toString().padLeft(2, '0')}/${entrada.data.month.toString().padLeft(2, '0')}/${entrada.data.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                    Icon(
                      getHumorIcon(entrada.humor),
                      size: 16,
                      color: getHumorColor(entrada.humor),
                    ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              entrada.titulo,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (entrada.tags.isNotEmpty) ...[
              SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: entrada.tags.take(3).map((tag) => 
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ],
            if (entrada.psicologoNome != null) ...[
              SizedBox(height: 8),
              Text(
                'Direcionado para: ${entrada.psicologoNome}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 20),
            Text(
              'Seu diário está vazio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Comece a escrever seus pensamentos e sentimentos',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Color(0xFF26C6DA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Center(
        child: Text(
          '${entradas.length} Notas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares
  List<EntradaDiario> _filtrarEntradas() {
    var resultado = entradas;
    
    if (_searchController.text.isNotEmpty) {
      resultado = resultado.where((entrada) =>
        entrada.titulo.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        entrada.conteudo.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    if (_filtroAtivo != 'todos') {
      resultado = resultado.where((entrada) =>
        entrada.humor.toString().split('.').last == _filtroAtivo
      ).toList();
    }
    
    return resultado;
  }

  int _entradasDoMes() {
    final agora = DateTime.now();
    return entradas.where((e) => 
      e.data.month == agora.month && e.data.year == agora.year
    ).length;
  }

  int _sequenciaAtual() {
    if (entradas.isEmpty) {
      return 0;
    }

    // Ordena as entradas da mais recente para a mais antiga
    final entradasOrdenadas = List<EntradaDiario>.from(entradas)
      ..sort((a, b) => b.data.compareTo(a.data));

    // Pega apenas as datas únicas, sem duplicatas no mesmo dia
    final datasUnicas = entradasOrdenadas.map((e) {
      return DateTime(e.data.year, e.data.month, e.data.day);
    }).toSet();

    if (datasUnicas.isEmpty) {
      return 0;
    }

    var hoje = DateTime.now();
    var hojeMeiaNoite = DateTime(hoje.year, hoje.month, hoje.day);
    
    // Se não houver entrada hoje nem ontem, a sequência é 0
    if (!datasUnicas.contains(hojeMeiaNoite) && !datasUnicas.contains(hojeMeiaNoite.subtract(const Duration(days: 1)))) {
      return 0;
    }

    int sequencia = 0;
    var diaAtual = hojeMeiaNoite;

    // Se não houver entrada hoje, começa a contar a partir de ontem
    if (!datasUnicas.contains(diaAtual)) {
      diaAtual = diaAtual.subtract(const Duration(days: 1));
    }

    // Itera para trás contando os dias consecutivos
    while (datasUnicas.contains(diaAtual)) {
      sequencia++;
      diaAtual = diaAtual.subtract(const Duration(days: 1));
    }

    return sequencia;
  }

  // Funções locais de humor removidas (usar getHumorColor/getHumorIcon de utils.dart)

  void _criarNovaEntrada() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovaEntradaScreen(
          onSalvar: (novaEntrada) async {
            try {
              final savedEntry = await ApiService.addDiaryEntry(
                titulo: novaEntrada.titulo,
                conteudo: novaEntrada.conteudo,
                humor: novaEntrada.humor,
                tags: novaEntrada.tags,
                psicologoId: novaEntrada.psicologoId,
              );
              if (!mounted) return;
              setState(() {
                entradas.insert(0, savedEntry);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    savedEntry.psicologoNome != null
                      ? 'Entrada direcionada para ${savedEntry.psicologoNome}'
                      : 'Entrada adicionada ao diário',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar: ${e.toString()}'), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ),
    );
  }

  void _abrirEntrada(EntradaDiario entrada) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesEntradaScreen(entrada: entrada),
      ),
    );
  }
}

// Tela de nova entrada
class NovaEntradaScreen extends StatefulWidget {
  final Function(EntradaDiario) onSalvar;

  NovaEntradaScreen({required this.onSalvar});

  @override
  _NovaEntradaScreenState createState() => _NovaEntradaScreenState();
}

class _NovaEntradaScreenState extends State<NovaEntradaScreen> {
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();
  final _tagsController = TextEditingController();
  Humor _humorSelecionado = Humor.neutro;
  String? _psicologoSelecionadoId;
  List<User> _psicologos = [];
  bool _isLoadingPsicologos = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _carregarPsicologos();
  }

  Future<void> _carregarPsicologos() async {
    try {
      final psicologos = await ApiService.getPsychologists();
      if (!mounted) return;
      setState(() {
        _psicologos = psicologos;
        _isLoadingPsicologos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPsicologos = false;
      });
      // Opcional: mostrar erro
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _salvarEntrada() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Correção: Usar `firstWhereOrNull` (do package:collection) ou uma busca manual segura
    // para evitar exceção se o psicólogo não for encontrado.
  final psicologoSelecionado = _psicologoSelecionadoId != null
    ? _psicologos.firstWhereOrNull((p) => p.id == _psicologoSelecionadoId)
    : null;

    final novaEntrada = EntradaDiario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: DateTime.now(),
      titulo: _tituloController.text,
      conteudo: _conteudoController.text,
      humor: _humorSelecionado,
      tags: _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      psicologoId: _psicologoSelecionadoId,
      psicologoNome: psicologoSelecionado?.name,
    );

    widget.onSalvar(novaEntrada);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Entrada no Diário'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.save),
              onPressed: _salvarEntrada,
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo Título
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Como foi seu dia?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O título é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Campo Conteúdo
              TextFormField(
                controller: _conteudoController,
                decoration: InputDecoration(
                  labelText: 'Conteúdo',
                  hintText: 'Escreva aqui seus pensamentos e sentimentos...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O conteúdo não pode ficar em branco';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Seletor de Psicólogo
              _isLoadingPsicologos
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _psicologoSelecionadoId,

                      decoration: InputDecoration(
                        labelText: 'Direcionar para Psicólogo (Opcional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _psicologos.map((User psicologo) {
                        return DropdownMenuItem<String>(
                          value: psicologo.id,
                          child: Text(psicologo.name),
                        );
                      }).toList(),
                      onChanged: (String? novoId) {
                        setState(() {
                          _psicologoSelecionadoId = novoId;
                        });
                      },
                    ),
              SizedBox(height: 20),

              // Seletor de Humor
              DropdownButtonFormField<Humor>(
                value: _humorSelecionado,
                decoration: InputDecoration(
                  labelText: 'Como você está se sentindo?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: Humor.values.map((Humor humor) {
                  return DropdownMenuItem<Humor>(
                    value: humor,
                    child: Row(
                      children: [
                        Icon(getHumorIcon(humor), color: getHumorColor(humor)),
                        SizedBox(width: 10),
                        Text(humor.toString().split('.').last.replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase())),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Humor? novoHumor) {
                  setState(() {
                    if (novoHumor != null) {
                      _humorSelecionado = novoHumor;
                    }
                  });
                },
              ),
              SizedBox(height: 20),

              // Campo Tags
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (separadas por vírgula)',
                  hintText: 'Ex: trabalho, ansiedade, gratidão',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 30),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Salvar Entrada'),
                  onPressed: _salvarEntrada,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Funções de ajuda para ícones e cores de humor (copiadas de DiarioScreen)
  // Removidas funções locais de humor (uso centralizado via utils)
}

// Tela de detalhes
class DetalhesEntradaScreen extends StatelessWidget {
  final EntradaDiario entrada;

  DetalhesEntradaScreen({required this.entrada});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrada do Diário'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getHumorIcon(entrada.humor), color: _getHumorColor(entrada.humor), size: 24),
                  SizedBox(width: 8),
                  Text(
                    '${entrada.data.day}/${entrada.data.month}/${entrada.data.year}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                entrada.titulo,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (entrada.psicologoNome != null) ...[
                SizedBox(height: 8),
                Text(
                  'Direcionado para: ${entrada.psicologoNome}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
                ),
              ],
              SizedBox(height: 24),
              Text(
                entrada.conteudo,
                style: TextStyle(fontSize: 18, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getHumorColor(Humor humor) {
    switch (humor) {
      case Humor.feliz: return Colors.green;
      case Humor.neutro: return Colors.orange;
      case Humor.triste: return Colors.blue;
      case Humor.ansioso: return Colors.red;
      case Humor.calmo: return Colors.teal;
      case Humor.orgulhoso: return Colors.purple;
      case Humor.reflexivo: return Colors.indigo;
    }
  }

  IconData _getHumorIcon(Humor humor) {
    switch (humor) {
      case Humor.feliz: return Icons.sentiment_very_satisfied;
      case Humor.neutro: return Icons.sentiment_neutral;
      case Humor.triste: return Icons.sentiment_dissatisfied;
      case Humor.ansioso: return Icons.psychology;
      case Humor.calmo: return Icons.self_improvement;
      case Humor.orgulhoso: return Icons.emoji_events;
      case Humor.reflexivo: return Icons.lightbulb;
    }
  }
}