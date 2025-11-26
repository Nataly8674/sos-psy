import 'package:flutter/material.dart';

class TipoUsuarioScreen extends StatefulWidget {
  @override
  _TipoUsuarioScreenState createState() => _TipoUsuarioScreenState();
}

class _TipoUsuarioScreenState extends State<TipoUsuarioScreen> {
  String? _tipoSelecionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tipo de Usuário'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou ícone
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.blue[700],
                ),
              ),
              
              // Título
              Text(
                'Você é:',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              SizedBox(height: 16),
              
              // Subtítulo
              Text(
                'Selecione o tipo de conta que deseja criar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: 50),
              
              // Card Paciente
              GestureDetector(
                onTap: () {
                  setState(() {
                    _tipoSelecionado = 'paciente';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _tipoSelecionado == 'paciente' 
                        ? Colors.blue[50] 
                        : Colors.white,
                    border: Border.all(
                      color: _tipoSelecionado == 'paciente' 
                          ? Colors.blue[700]! 
                          : Colors.grey[300]!,
                      width: _tipoSelecionado == 'paciente' ? 2 : 1,
                    ),
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
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.blue[700],
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paciente',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Busco ajuda psicológica e suporte emocional',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_tipoSelecionado == 'paciente')
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
              
              // Card Psicólogo
              GestureDetector(
                onTap: () {
                  setState(() {
                    _tipoSelecionado = 'psicologo';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _tipoSelecionado == 'psicologo' 
                        ? Colors.blue[50] 
                        : Colors.white,
                    border: Border.all(
                      color: _tipoSelecionado == 'psicologo' 
                          ? Colors.blue[700]! 
                          : Colors.grey[300]!,
                      width: _tipoSelecionado == 'psicologo' ? 2 : 1,
                    ),
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
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.psychology,
                          color: Colors.green[700],
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Psicólogo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sou um profissional e ofereço consultoria',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_tipoSelecionado == 'psicologo')
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              // Botão Continuar
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _tipoSelecionado != null ? () {
                    if (_tipoSelecionado == 'paciente') {
                      Navigator.pushNamed(context, '/novo-paciente');
                    } else if (_tipoSelecionado == 'psicologo') {
                      Navigator.pushNamed(context, '/novo-psicologo');
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tipoSelecionado != null 
                        ? Colors.blue[700] 
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}