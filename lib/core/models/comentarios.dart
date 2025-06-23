class Comentario {
  final String usuario;
  final String texto;
  final DateTime data;

  Comentario({
    required this.usuario,
    required this.texto,
    required this.data,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      usuario: json['usuario'],
      texto: json['texto'],
      data: DateTime.parse(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'texto': texto,
      'data': data.toIso8601String(),
    };
  }
}