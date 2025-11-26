import 'package:flutter/material.dart';

class EquipeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Nossa Equipe'),
        backgroundColor: Color(0xFF26C6DA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
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
                  Icon(
                    Icons.groups,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Conheça Nossa Equipe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Estudantes de ADS dedicados a transformar a saúde mental',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Membros da equipe
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTeamMember(
                    name: 'Natália de Castilho Carvalho',
                    role: 'Fundadora & Desenvolvedora Front-End',
                    course: 'Análise e Desenvolvimento de Sistemas',
                    period: '5º Período',
                    contribution: 'Responsável pelo design e desenvolvimento da interface do usuário, criando experiências visuais intuitivas e acessíveis.',
                    description: 'Apaixonada por UI/UX e desenvolvimento mobile, Natália lidera a criação das telas do aplicativo com foco em proporcionar uma experiência fluida e acolhedora para os usuários. Acredita que um bom design pode fazer toda a diferença no cuidado com a saúde mental.',
                    icon: Icons.palette,
                    iconColor: Colors.pink,
                    imagePath: 'assets/images/Ft-Perfil-Nat1.jpeg',
                  ),
                  
                  _buildTeamMember(
                    name: 'Gabriel Douglas Santos Melo da Fonseca',
                    role: 'Co-Fundador & Especialista em Apresentação',
                    course: 'Análise e Desenvolvimento de Sistemas',
                    period: '5º Período',
                    contribution: 'Responsável pela apresentação do aplicativo, comunicação com stakeholders e demonstração das funcionalidades do sistema.',
                    description: 'Com excelente habilidade de comunicação e apresentação, Gabriel é a voz do SOS PSY. Especializado em traduzir conceitos técnicos para uma linguagem acessível, ele apresenta o aplicativo de forma envolvente e clara, conectando a equipe com potenciais usuários e parceiros.',
                    icon: Icons.architecture,
                    iconColor: Colors.blue,
                    imagePath: 'assets/images/Ft-Perfil-Gabriel.jpeg',
                  ),
                  
                  _buildTeamMember(
                    name: 'Adrya Kauane Santos Gama',
                    role: 'Co-Fundadora & Designer UI/UX',
                    course: 'Análise e Desenvolvimento de Sistemas',
                    period: '5º Período',
                    contribution: 'Responsável pela criação do design das telas do projeto, focando em usabilidade e estética visual.',
                    description: 'Sempre em busca de me aprofundar mais na área de design e poder proporcionar uma experiência do usuário mais intuitiva e agradável. Adrya trabalha cuidadosamente em cada detalhe visual para que o aplicativo seja não apenas funcional, mas também visualmente harmonioso e acolhedor.',
                    icon: Icons.storage,
                    iconColor: Colors.purple,
                    imagePath: 'assets/images/Ft-Perfil-Adrya.jpeg',
                  ),
                  
                  _buildTeamMember(
                    name: 'Matheus de Santana Andrade',
                    role: 'Co-Fundador & Desenvolvedor de Componentes',
                    course: 'Análise e Desenvolvimento de Sistemas',
                    period: '5º Período',
                    contribution: 'Responsável pela criação de widgets personalizados, como botões e cards, além de campos de formulário com design adaptado ao tema do aplicativo.',
                    description: 'Especializado em desenvolvimento de componentes reutilizáveis, Matheus constrói os elementos fundamentais que compõem a interface do SOS PSY. Seu trabalho garante consistência visual e facilita a manutenção do código, criando uma biblioteca de componentes robusta e elegante.',
                    icon: Icons.code,
                    iconColor: Colors.green,
                    imagePath: 'assets/images/Ft-Perfil-Matheus.jpeg',
                  ),
                  
                  _buildTeamMember(
                    name: 'Ítalo Matheus Santos da Silva',
                    role: 'Co-Fundador & Desenvolvedor de Interface',
                    course: 'Análise e Desenvolvimento de Sistemas',
                    period: '5º Período',
                    contribution: 'Responsável pelo desenvolvimento da interface, implementando telas e funcionalidades que proporcionam uma navegação fluida.',
                    description: 'Sou uma pessoa dedicada, com interesse em tecnologia e desenvolvimento de soluções práticas. Busco sempre aprimorar meus conhecimentos e contribuir para projetos que unam funcionalidade e boa experiência do usuário. Ítalo trabalha na implementação técnica das interfaces, transformando designs em código funcional.',
                    icon: Icons.verified_user,
                    iconColor: Colors.orange,
                    imagePath: 'assets/images/Ft-Perfil-Italo.jpeg',
                  ),
                  
                  // Seção sobre o projeto
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
                        Icon(
                          Icons.lightbulb,
                          color: Color(0xFF26C6DA),
                          size: 40,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Projeto Acadêmico com Propósito',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'O SOS PSY nasceu como projeto acadêmico do curso de Análise e Desenvolvimento de Sistemas, mas foi desenvolvido com um propósito maior: facilitar o acesso à saúde mental através da tecnologia. Nossa equipe multidisciplinar combina conhecimentos técnicos com sensibilidade social para criar uma solução que realmente faça a diferença na vida das pessoas.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // Seção de valores da equipe
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
                        Icon(
                          Icons.favorite,
                          color: Color(0xFF26C6DA),
                          size: 40,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Trabalhamos com Dedicação',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Cada membro da equipe traz suas habilidades únicas e paixão pela tecnologia para criar uma plataforma que seja não apenas funcional, mas também empática e centrada no usuário. Acreditamos que a saúde mental deve ser acessível a todos.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // Chamada para ação
                  Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF26C6DA), Color(0xFF00BCD4)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.email,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Entre em Contato',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tem sugestões ou quer saber mais sobre o projeto? Adoraríamos ouvir você!',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Implementar ação de contato
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Contato'),
                                content: Text('Email: equipe.sospsy@gmail.com\n\nEstamos sempre abertos a feedbacks e sugestões!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Fechar'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF26C6DA),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send),
                              SizedBox(width: 8),
                              Text(
                                'Enviar Mensagem',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
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
  
  Widget _buildTeamMember({
    required String name,
    required String role,
    required String course,
    required String period,
    required String contribution,
    required String description,
    required IconData icon,
    required Color iconColor,
    String? imagePath,
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: iconColor.withOpacity(0.2),
                backgroundImage: imagePath != null ? AssetImage(imagePath) : null,
                child: imagePath == null
                    ? Icon(
                        Icons.person,
                        size: 35,
                        color: iconColor,
                      )
                    : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.school, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$course - $period',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: iconColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: 18,
                  color: iconColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contribution,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}