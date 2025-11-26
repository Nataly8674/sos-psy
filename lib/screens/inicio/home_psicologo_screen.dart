import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HomePsicologoScreen extends StatelessWidget {
  const HomePsicologoScreen({super.key});

  String _saudacao() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final nome = (user?.name ?? '').trim();
    return Scaffold(
      appBar: AppBar(
        title: Text('Área do Psicólogo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_saudacao()}, ${nome.isNotEmpty ? nome.split(' ').first : 'Profissional'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bem-vindo à sua área profissional.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: const [
                    Icon(Icons.event_available, color: Colors.teal),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Em breve: agenda de pacientes, próximos atendimentos e gerenciamento de horários.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
