// Modelo de entrada de diário e enum de Humor
// Removido import incorreto da tela para evitar dependência circular.

enum Humor { feliz, neutro, triste, ansioso, calmo, orgulhoso, reflexivo }

class EntradaDiario {
  final String id;
  final DateTime data;
  final String titulo;
  final String conteudo;
  final Humor humor;
  final List<String> tags;
  final String? psicologoId;
  final String? psicologoNome;

  EntradaDiario({
    required this.id,
    required this.data,
    required this.titulo,
    required this.conteudo,
    required this.humor,
    this.tags = const [],
    this.psicologoId,
    this.psicologoNome,
  });

  factory EntradaDiario.fromJson(Map<String, dynamic> json) {
    return EntradaDiario(
      id: json['id'],
      data: DateTime.parse(json['data']),
      titulo: json['titulo'],
      conteudo: json['conteudo'],
      humor: Humor.values.firstWhere((h) => h.toString() == 'Humor.${json['humor']}', orElse: () => Humor.neutro),
      tags: List<String>.from(json['tags'] ?? []),
      psicologoId: json['psicologoId'],
      psicologoNome: json['psicologoNome'],
    );
  }
}
