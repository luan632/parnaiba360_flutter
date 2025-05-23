import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({super.key});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  final MapController _mapController = MapController();
  final LatLng parnaibaLocation = const LatLng(-2.9038, -41.7767);
  String selectedFilter = 'Todos';

  // Lista de pontos turísticos com nome e coordenadas
  final List<Map<String, dynamic>> pontosTuristicos = [
  {'nome': "Praça Mandu Ladino", 'lat': -2.902957, 'lng': -41.768434},
  {'nome': "Parnaíba Shopping", 'lat': -2.909734, 'lng': -41.746951},
  {'nome': "Praia Pedra do Sal", 'lat': -2.816892, 'lng': -41.728505},
  {'nome': "Lagoa do Portinho", 'lat': -2.963750, 'lng': -41.683123},
  // Adicione mais pontos turísticos aqui
];

  // Lista de hotéis com nome e coordenadas
  final List<Map<String, dynamic>> hoteis = [
    {'nome': 'Citi Executivo Hotel', 'lat': -2.913962, 'lng': -41.753847},
    {'nome': 'Hotel Portal dos Ventos', 'lat': -2.908528, 'lng': -41.752094},
    // Adicione mais hotéis aqui
  ];

  // Lista de restaurantes com nome e coordenadas
  final List<Map<String, dynamic>> restaurantes = [
    {'nome': 'Restaurante 1', 'lat': -2.910237, 'lng': -41.744985},
    // Adicione mais restaurantes aqui
  ];

  // Método para gerar marcadores a partir de uma lista
  List<Map<String, dynamic>> _generateMarkers(
      List<Map<String, dynamic>> locations, String type, Color color) {
    return locations.map((location) {
      return {
        'type': type,
        'nome': location['nome'],
        'marker': Marker(
          point: LatLng(location['lat'], location['lng']),
          builder: (_) => Icon(
            type == 'Ponto Turístico' ? Icons.location_on : 
            type == 'Hotel' ? Icons.hotel : Icons.restaurant,
            color: color,
          ),
          width: 30,
          height: 30,
          anchorPos: AnchorPos.align(AnchorAlign.top),
        ),
      };
    }).toList();
  }

  // Método para obter todos os marcadores filtrados
  List<Marker> getFilteredMarkers() {
    List<Map<String, dynamic>> allMarkers = [];
    
    allMarkers.addAll(_generateMarkers(pontosTuristicos, 'Ponto Turístico', Colors.red));
    allMarkers.addAll(_generateMarkers(hoteis, 'Hotel', Colors.blue));
    allMarkers.addAll(_generateMarkers(restaurantes, 'Restaurante', Colors.green));

    if (selectedFilter == 'Todos') {
      return allMarkers.map((m) => m['marker'] as Marker).toList();
    } else {
      return allMarkers
          .where((marker) => marker['type'] == selectedFilter)
          .map((m) => m['marker'] as Marker)
          .toList();
    }
  }

  void _applyFilter(String? filter) {
    if (filter != null) {
      setState(() {
        selectedFilter = filter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Parnaiba360'),
        backgroundColor: Colors.blue,
        actions: [
          // Menu popup para seleção de filtros
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Todos',
                child: Text('Todos'),
              ),
              const PopupMenuItem(
                value: 'Ponto Turístico',
                child: Text('Pontos Turísticos'),
              ),
              const PopupMenuItem(
                value: 'Hotel',
                child: Text('Hotéis'),
              ),
              const PopupMenuItem(
                value: 'Restaurante',
                child: Text('Restaurantes'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Widget principal do mapa FlutterMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: parnaibaLocation, // Centro inicial do mapa
              zoom: 13, // Zoom inicial
              minZoom: 0,
              maxZoom: 100,
            ),
            children: [
              // Camada de tiles do OpenStreetMap
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", 
              ),
              // Camada que mostra a localização atual do usuário
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              // Camada de marcadores (filtrada)
              MarkerLayer(markers: getFilteredMarkers()),
            ],
          ),
        ],
      ),
      // Botão para centralizar o mapa na localização de Parnaíba
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