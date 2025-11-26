import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final String psicologo;
  final String? patientName; // Novo campo para o nome do paciente
  final String especialidade;
  final double avaliacao;
  final int totalAvaliacoes;
  final DateTime data;
  final String horario;
  final String local;
  final String imagemPsicologo;
  final String modalidade;
  final String motivo;

  Appointment({
    required this.id,
    required this.psicologo,
    this.patientName,
    required this.especialidade,
    required this.avaliacao,
    required this.totalAvaliacoes,
    required this.data,
    required this.horario,
    required this.local,
    required this.imagemPsicologo,
    required this.modalidade,
    required this.motivo,
  });

  // Getters para data e hora formatadas
  String get formattedDate => DateFormat('d \'de\' MMMM \'de\' y', 'pt_BR').format(data);
  String get formattedTime => horario;

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: (json['id'] ?? '') as String,
        psicologo: (json['psicologo'] ?? '') as String,
        patientName: json['patientName'] as String?, // Mapeando o novo campo
        especialidade: (json['especialidade'] ?? '') as String,
        avaliacao: (json['avaliacao'] is int)
            ? (json['avaliacao'] as int).toDouble()
            : (json['avaliacao'] ?? 0.0).toDouble(),
        totalAvaliacoes: (json['totalAvaliacoes'] ?? 0) as int,
        data: DateTime.parse(json['data'] as String),
        horario: (json['horario'] ?? '') as String,
        local: (json['local'] ?? '') as String,
        imagemPsicologo: (json['imagemPsicologo'] ?? '') as String,
        modalidade: (json['modalidade'] ?? 'Presencial') as String,
        motivo: (json['motivo'] ?? '') as String,
      );
}
