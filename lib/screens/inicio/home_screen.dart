import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/appointment.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Appointment> _proximas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarConsultas();
  }

  Future<void> _carregarConsultas() async {
    try {
      final list = await ApiService.getAppointments();
      if (!mounted) return;
      setState(() {
        _proximas = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _proximas = [];
        _loading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'S.O.S - Psicologia',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            
            // Card principal com boas-vindas
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan[400]!, Colors.cyan[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo/Nome do app
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'S.O.S Psicologia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Saudação dinâmica
                  Text(
                    _saudacaoComNome(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Descrição (bem-vindo)
                  Text(
                    'Bem-vindo ao seu espaço de cuidado e bem-estar. Gerencie suas consultas e escreva o que está sentindo.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Menu de ações rápidas
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildActionButtonsForRole(),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Seção "Próximas Consultas" (somente se houver consultas)
            if (_loading)
              Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_proximas.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.grey[700], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Próximas Consultas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ..._proximas.take(3).map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildConsultaCard(
                            nome: c.psicologo,
                            tipo: c.especialidade,
                            horario: c.horario,
                          ),
                        )),
                    if (_proximas.length > 3) ...[
                      SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/consultas-agendadas');
                          },
                          child: Text(
                            'Ver todas as consultas',
                            style: TextStyle(
                              color: Colors.cyan[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            
            SizedBox(height: 30),
            
            // NOVAS IMAGENS ADICIONADAS
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Primeira imagem
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/imagem1.jpg',
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
                  
                  SizedBox(height: 16),
                  
                ],
              ),
            ),
            
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final isPsychologist = ApiService.currentUser?.role == 'psychologist';

    return Drawer(
      child: Column(
        children: [
          // Header do drawer com perfil do usuário - AGORA CLICÁVEL
          InkWell(
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              Navigator.pushNamed(context, '/perfil-usuario'); // Navega para o perfil
            },
            child: Container(
              padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              color: Colors.white,
              child: Row(
                children: [
                  // Avatar do usuário
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    // backgroundImage: AssetImage('assets/images/ana_silva.jpg'), // opcional
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 15),
                  // Nome do usuário
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nomeUsuario(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Toque para ver perfil',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ícone indicando que é clicável
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          
          // Divisor
          Divider(height: 1, color: Colors.grey[200]),
          
          SizedBox(height: 10),
          
          // Seção "Navegação Principal"
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Navegação Principal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          // Menu items
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Início',
            subtitle: 'Página inicial',
            isSelected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          
          if (isPsychologist)
            _buildDrawerItem(
              icon: Icons.event_note,
              title: 'Minhas Consultas',
              subtitle: 'Consultas agendadas com você',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/consultas-psicologo');
              },
            ),

          if (!isPsychologist)
            _buildDrawerItem(
              icon: Icons.event_available,
              title: 'Meus Agendamentos',
              subtitle: 'Suas consultas marcadas',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/consultas-agendadas');
              },
            ),
          
          if (!isPsychologist)
            _buildDrawerItem(
              icon: Icons.people,
              title: 'Psicólogos Disponíveis',
              subtitle: 'Encontre profissionais',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/psicologos-disponiveis');
              },
            ),
          
          _buildDrawerItem(
            icon: Icons.book,
            title: 'Diário',
            subtitle: 'Registre suas emoções',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/diario');
            },
          ),

          // Spacer para empurrar o "Sair" para baixo
          const Spacer(),
          
          // Divisor antes do "Sair"
          Divider(height: 1, color: Colors.grey[200]),
          
          // Botão Sair
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Sair',
            subtitle: null,
            textColor: Colors.red[600],
            iconColor: Colors.red[600],
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isSelected = false,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
            ? Colors.blue[600] 
            : (iconColor ?? Colors.grey[600]),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected 
              ? Colors.blue[600] 
              : (textColor ?? Colors.black87),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: subtitle != null 
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            )
          : null,
        onTap: onTap,
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sair'),
          content: Text('Tem certeza de que deseja sair do aplicativo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[600],
              ),
              child: Text('Sair'),
            ),
          ],
        );
      },
    );
  }

List<Widget> _buildActionButtonsForRole() {
  final userRole = ApiService.currentUser?.role;
  List<Widget> buttons = [];

    // Botões para psicólogos
    if (userRole == 'psychologist') {
      buttons.add(
        _buildActionButton(
          icon: Icons.event_note,
          label: 'Minhas Consultas',
          color: Colors.blue[600]!,
          onTap: () {
            Navigator.pushNamed(context, '/consultas-psicologo');
          },
        ),
      );
    }
    // Botões para pacientes
    else {
      buttons.add(
        _buildActionButton(
          icon: Icons.calendar_today,
          label: 'Agendamento',
          color: Colors.blue[600]!,
          onTap: () {
            Navigator.pushNamed(context, '/agendar-consulta');
          },
        ),
      );
      buttons.add(
        _buildActionButton(
          icon: Icons.people,
          label: 'Psicólogos',
          color: Colors.green[600]!,
          onTap: () {
            Navigator.pushNamed(context, '/psicologos-disponiveis');
          },
        ),
      );
    }

    // Botão comum a todos
    buttons.add(
      _buildActionButton(
        icon: Icons.book,
        label: 'Diário',
        color: Colors.purple[600]!,
        onTap: () {
          Navigator.pushNamed(context, '/diario');
        },
      ),
    );

  return buttons;
}

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultaCard({
    required String nome,
    required String tipo,
    required String horario,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Avatar do paciente
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          
          SizedBox(width: 16),
          
          // Informações da consulta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  tipo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Horário
          Text(
            horario,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.cyan[600],
            ),
          ),
        ],
      ),
    );
  }

  String _saudacaoComNome() {
    final now = DateTime.now().hour;
    String saudacao;
    if (now >= 5 && now < 12) {
      saudacao = 'Bom dia';
    } else if (now >= 12 && now < 18) {
      saudacao = 'Boa tarde';
    } else {
      saudacao = 'Boa noite';
    }
    final name = _primeiroNome(_nomeUsuario());
    return '$saudacao, $name!';
  }

  String _nomeUsuario() {
    final user = ApiService.currentUser;
    if (user == null) return 'Usuário';
    return (user.name.isNotEmpty) ? user.name : (user.email.split('@').first);
  }

  String _primeiroNome(String nomeCompleto) {
    final parts = nomeCompleto.trim().split(' ');
    return parts.isNotEmpty ? parts.first : nomeCompleto;
  }
}