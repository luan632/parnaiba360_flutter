

class PontosTuristicos{
  final int id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;

  PontosTuristicos({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude
  });

  factory PontosTuristicos.fromJson(Map<String, dynamic>json){
    return PontosTuristicos(
      id: json['id'], 
      nome: json['nome'], 
      descricao: json['descricao'], 
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString())
      );
  }
}