import 'package:flutter/material.dart';

class SobreNosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Sobre Nós'),
        backgroundColor: Color(0xFF26C6DA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com gradiente
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF26C6DA), Color(0xFF00BCD4)],
                ),
              ),
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.psychology, size: 80, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'SOS PSY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cuidando da sua saúde mental',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    icon: Icons.favorite,
                    title: 'Nossa Missão',
                    content:
                        'Proporcionar acesso facilitado e humanizado a serviços de saúde mental, conectando pacientes a profissionais qualificados através de uma plataforma segura e intuitiva.',
                  ),

                  _buildSection(
                    icon: Icons.visibility,
                    title: 'Nossa Visão',
                    content:
                        'Ser referência em telemedicina para saúde mental, democratizando o acesso a tratamentos psicológicos e contribuindo para uma sociedade mais saudável emocionalmente.',
                  ),

                  _buildSection(
                    icon: Icons.star,
                    title: 'Nossos Valores',
                    content:
                        '• Empatia e acolhimento\n• Privacidade e segurança\n• Qualidade no atendimento\n• Inovação constante\n• Compromisso com a saúde mental',
                  ),

                  _buildSection(
                    icon: Icons.info,
                    title: 'Sobre a Plataforma',
                    content:
                        'O SOS PSY nasceu da necessidade de facilitar o acesso a atendimento psicológico de qualidade. Nossa plataforma conecta pacientes a psicólogos qualificados, permitindo consultas online seguras, agendamento facilitado e acompanhamento contínuo do tratamento.',
                  ),

                  // Estatísticas
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Nossos Números',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat('1000+', 'Pacientes'),
                            _buildStat('150+', 'Psicólogos'),
                            _buildStat('5000+', 'Consultas'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Contato
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.contact_mail, color: Color(0xFF26C6DA)),
                            SizedBox(width: 12),
                            Text(
                              'Entre em Contato',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildContactItem(Icons.email, 'contato@sospsy.com.br'),
                        _buildContactItem(Icons.phone, '(11) 99999-9999'),
                        _buildContactItem(Icons.language, 'www.sospsy.com.br'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF26C6DA)),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF26C6DA),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
