

class PontosTuristicos{
  final int id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;
  final String tipo;

  PontosTuristicos({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.tipo,
  });

  factory PontosTuristicos.fromJson(Map<String, dynamic> json){
    return PontosTuristicos(
      id: json['id'], 
      nome: json['nome'], 
      descricao: json['descricao'], 
      latitude: json['latitude'], 
      longitude: json['longitude'], 
      tipo: json['tipo']
    );
    
  }
}