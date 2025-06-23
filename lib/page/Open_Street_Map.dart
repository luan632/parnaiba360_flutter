import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

import 'package:parnaiba360_flutter/core/service/auth/auth_service.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_mock_service.dart';
import 'package:parnaiba360_flutter/core/models/pontos_turisticos.dart';
import 'package:parnaiba360_flutter/core/service/api_services.dart';

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

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({super.key});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  final MapController _mapController = MapController();
  final LatLng parnaibaLocation = const LatLng(-2.9038, -41.7767);
  String selectedFilter = 'Ponto Turístico';
  final AuthService _authService = AuthMockService();

  late Future<List<PontosTuristicos>> futurePontos;

  @override
  void initState() {
    super.initState();
    futurePontos = ApiServices().getPontos();
  }

  // Pontos Turísticos
  final List<Map<String, dynamic>> pontosTuristicos = [
    {
      'nome': "Praça Mandu Ladino",
      'lat': -2.902870,
      'lng': -41.768831,
      'descricao': "A Praça Mandu Ladino é um espaço histórico da cidade.",
      'endereco': "Rua Paul Harris - Nossa Sra. de Fátima, Parnaíba - PI, 64202-400",
      'imagem': 'assets/images/quadrilhodromo.jpg',
      'comentarios': <Comentario>[],
    },
    {
      'nome': "Parnaíba Shopping",
      'lat': -2.909734,
      'lng': -41.746951,
      'descricao': "O Parnaíba Shopping é o único centro de compras, serviços e entretenimento da região do litoral do Piauí.",
      'endereco': "Av. São Sebastião, 3429 - Reis Veloso, Parnaíba - PI, 64204-035",
      'imagem': 'assets/images/Parnaiba-Shopping.jpg',
      'comentarios': <Comentario>[],
    },
    {
      'nome': "Praia Pedra do Sal",
      'lat': -2.805365,
      'lng': -41.729110,
      'descricao': "Praia famosa pela pesca artesanal e gastronomia local.",
      'endereco': "Pedra do Sal, Parnaíba - PI",
      'imagem': 'assets/images/Pedra-do-Sal.png',
      'comentarios': <Comentario>[],
    },
    {
      'nome': "Lagoa do Portinho",
      'lat': -2.931272,
      'lng': -41.676872,
      'descricao': "Área de lazer com lago natural e trilhas ecológicas mais também pela sua lenda que envolve amor, rivalidade tribal e a intervenção do deus Tupã, conta que a lagoa surgiu das lágrimas de Macyrajara, uma índia da tribo dos Tremembés, após a morte de seu amado Ubitã, guerreiro de uma tribo rival.",
      'endereco': "Estrada Portinho, Parnaíba - PI",
      'imagem': 'assets/images/lagoa.webp',
      'comentarios': <Comentario>[],
    },
  ];

  // Hotéis
  final List<Map<String, dynamic>> hoteis = [
    {
      'nome': 'Hotel Cívico',
      'lat': -2.903465,
      'lng': -41.773410,
      'descricao': "Hotel moderno e bem localizado no centro comercial.",
      'endereco': "Av. Chagas Rodrigues, 474 - Centro, Parnaíba - PI, 64200-490",
      'imagem': 'assets/images/Hotel-Civico.jpg',
      'comentarios': <Comentario>[],
    },
    {
      'nome': 'Hotel Delta',
      'lat': -2.902006,
      'lng': -41.779482,
      'descricao': "Localizado próximo ao centro histórico da cidade o Porto das Barcas.",
      'endereco': "Av. Pres. Getúlio Vargas, 268 - Centro, Parnaíba - PI, 64200-200",
      'imagem': 'assets/images/hotel-delta-parnaiba.jpg',
      'comentarios': <Comentario>[],
    },
  ];

  // Restaurantes
  final List<Map<String, dynamic>> restaurantes = [
    {
      'nome': 'Restaurante Mangata',
      'lat': -2.910322,
      'lng': -41.744839,
      'descricao': "Comida regional e pratos internacionais.",
      'endereco': "Av. São Sebastião, 3900 - Frei Higino, Parnaíba - PI, 64207-005",
      'imagem': 'assets/images/Mangata.jpg',
      'comentarios': <Comentario>[],
    },
    {
      'nome': 'Restaurante Don Ladino',
      'lat': -2.903190,
      'lng': -41.768249,
      'descricao': "Comida regional e pratos internacionais.",
      'endereco': "Rua Padre Raimundo José Viêira, 378 - Nossa Sra. de Fátima, Parnaíba - PI, 64202-340",
      'imagem': 'assets/images/ambiente-externo.jpg',
      'comentarios': <Comentario>[],
    },
  ];

  // Gera marcadores dinamicamente
  List<Map<String, dynamic>> _generateMarkers(
      List<Map<String, dynamic>> locations, String type, Color color) {
    return locations.map((location) {
      return {
        'type': type,
        'nome': location['nome'],
        'marker': Marker(
          point: LatLng(location['lat'], location['lng']),
          width: 30,
          height: 30,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (_) => GestureDetector(
            onTap: () {
              _showMarkerInfo(context, location);
            },
            child: Icon(
              type == 'Ponto Turístico'
                  ? Icons.location_on
                  : type == 'Hotel'
                      ? Icons.hotel
                      : Icons.restaurant,
              color: color,
            ),
          ),
        ),
      };
    }).toList();
  }

  // Exibe informações do marcador em diálogo
  void _showMarkerInfo(BuildContext context, Map<String, dynamic> info) {
    final TextEditingController _comentarioController = TextEditingController();
    List<Comentario> comentarios = [];
    
    if (info['comentarios'] != null && info['comentarios'] is List) {
      comentarios = (info['comentarios'] as List).whereType<Comentario>().toList();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info['nome'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (info['imagem'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        info['imagem'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    info['descricao'] ?? info['descricao'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          info['endereco'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Seção de Comentários
                  const Divider(),
                  const Text(
                    'Comentários',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  if (comentarios.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nenhum comentário ainda. Seja o primeiro a comentar!'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comentarios.length,
                      itemBuilder: (context, index) {
                        final comentario = comentarios[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comentario.usuario,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${comentario.data.day}/${comentario.data.month}/${comentario.data.year}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comentario.texto,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  
                  // Campo para adicionar novo comentário
                  const SizedBox(height: 16),
                  TextField(
                    controller: _comentarioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deixe seu comentário',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          if (_comentarioController.text.trim().isNotEmpty) {
                            final novoComentario = Comentario(
                              usuario: _authService.currentUser?.displayName ?? 'Anônimo',
                              texto: _comentarioController.text.trim(),
                              data: DateTime.now(),
                            );
                            
                            setState(() {
                              setStateDialog(() {
                                comentarios.insert(0, novoComentario);
                                info['comentarios'] = comentarios;
                              });
                            });
                            
                            _comentarioController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comentário adicionado!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Retorna marcadores filtrados
  List<Marker> getFilteredMarkers() {
    List<Map<String, dynamic>> allMarkers = [];
    allMarkers.addAll(_generateMarkers(pontosTuristicos, 'Ponto Turístico', Colors.red));
    allMarkers.addAll(_generateMarkers(hoteis, 'Hotel', Colors.blue));
    allMarkers.addAll(_generateMarkers(restaurantes, 'Restaurante', Colors.orange));

    return allMarkers
        .where((marker) => marker['type'] == selectedFilter)
        .map((m) => m['marker'] as Marker)
        .toList();
  }

  // Aplica filtro ou logout
  void _applyFilter(String? filter) {
    if (filter != null) {
      if (filter == 'Sair') {
        _confirmLogout(context);
      } else {
        setState(() {
          selectedFilter = filter;
        });
      }
    }
  }

  // Confirma logout
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.yellowAccent, size: 28),
            const SizedBox(width: 10),
            Text(
              'Parnaíba360',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Ponto Turístico',
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Pontos Turísticos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Hotel',
                child: Row(
                  children: [
                    Icon(Icons.hotel, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Hotéis'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Restaurante',
                child: Row(
                  children: [
                    Icon(Icons.restaurant, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Restaurantes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Sair',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Sair', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: parnaibaLocation,
              zoom: 13,
              minZoom: 0,
              maxZoom: 100,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", 
              ),
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              MarkerLayer(markers: getFilteredMarkers()),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(parnaibaLocation, 13);
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.my_location,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}