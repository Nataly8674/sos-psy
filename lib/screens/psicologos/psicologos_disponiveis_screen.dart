import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class PsicologosDisponiveisScreen extends StatefulWidget {
  const PsicologosDisponiveisScreen({super.key});

  @override
  _PsicologosDisponiveisScreenState createState() =>
      _PsicologosDisponiveisScreenState();
}

class _PsicologosDisponiveisScreenState
    extends State<PsicologosDisponiveisScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _psicologos = [];
  List<User> _psicologosFiltrados = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarPsicologos();
    _psicologosFiltrados = _psicologos;
  }

  void _carregarPsicologos() async {
    try {
      final list = await ApiService.getPsychologists();
      setState(() {
        _psicologos = list;
        _psicologosFiltrados = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar psicólogos: $e';
        _loading = false;
      });
    }
  }

  void _filtrarPsicologos(String query) {
    setState(() {
      if (query.isEmpty) {
        _psicologosFiltrados = _psicologos;
      } else {
        _psicologosFiltrados = _psicologos.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase()) ||
              (p.specialty ?? '').toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header com gradiente
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan[400]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // AppBar personalizada
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          'Psicólogos Disponíveis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                
                // Conteúdo do header
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encontre seu\nPsicólogo Ideal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Conecte-se com profissionais qualificados\npara cuidar da sua saúde mental',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Campo de busca
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filtrarPsicologos,
                          decoration: InputDecoration(
                            hintText: 'Busque por nome, especialidade ou local',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contador e lista
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              child: Text(
                                '${_psicologosFiltrados.length} psicólogos encontrados',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                children: [
                                  ..._psicologosFiltrados
                                      .map((p) => _buildPsicologoCard(p))
                                      .toList(),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/imagem2.jpg',
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPsicologoCard(User psicologo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto do psicólogo
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: psicologo.profileImageUrl != null
                      ? NetworkImage(psicologo.profileImageUrl!)
                      : null,
                  child: psicologo.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          color: Colors.grey[600],
                          size: 30,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Informações do psicólogo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        psicologo.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Tag de especialidade
                      if (psicologo.specialty != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            psicologo.specialty!,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Avaliação
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${psicologo.rating ?? 0.0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            ' (${psicologo.reviewCount ?? 0} avaliações)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bio
            if (psicologo.bio != null && psicologo.bio!.isNotEmpty)
              Text(
                psicologo.bio!,
                style: TextStyle(color: Colors.grey[700], height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 16),

            // Preço e botão agendar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${psicologo.price?.toStringAsFixed(2) ?? 'N/A'}/sessão',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      _agendarConsulta(psicologo);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[500],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text(
                      'Agende sua consulta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _agendarConsulta(User psicologo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agendar Consulta'),
          content: Text('Deseja agendar uma consulta com ${psicologo.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/agendar-consulta');
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}