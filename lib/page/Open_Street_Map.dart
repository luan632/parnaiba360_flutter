import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_service.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_mock_service.dart';
import 'package:parnaiba360_flutter/core/models/pontos_turisticos.dart';
import 'package:parnaiba360_flutter/core/service/api_services.dart';

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({super.key});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  final MapController _mapController = MapController();
  final LatLng parnaibaLocation = LatLng(-2.9038, -41.7767);
  String selectedFilter = 'Todos';
  final AuthService _authService = AuthMockService();
  late Future<List<PontosTuristicos>> futurePontos;


    final List<Map<String, dynamic>> hotel = [
      {'nome': 'Hotel Exemplo', 'lat': -2.9038, 'lng': -41.7767},
    ];

    final List<Map<String, dynamic>> restaurant = [
    {'nome': 'Restaurante Exemplo', 'lat': -2.9040, 'lng': -41.7770},
    ];

  @override
  void initState() {
    super.initState();
    futurePontos = ApiServices().getPontos(); // Carrega pontos turísticos da API
  }

  // Função para gerar marcadores a partir dos dados da API
  List<Map<String, dynamic>> _generateMarkersFromApi(List<PontosTuristicos> pontos) {
    return pontos.map((ponto) {
      IconData iconData;
      Color markerColor;

      switch (ponto.tipo.toLowerCase()) {
        case 'turístico':
          iconData = Icons.location_on;
          markerColor = Colors.orange;
          break;
        case 'histórico':
          iconData = Icons.location_city;
          markerColor = Colors.brown;
          break;
        case 'restaurante':
          iconData = Icons.restaurant;
          markerColor = Colors.green;
          break;
        case 'hotel':
          iconData = Icons.hotel;
          markerColor = Colors.blue;
          break;
        default:
          iconData = Icons.place;
          markerColor = Colors.red;
      }

      return {
        'type': ponto.tipo,
        'nome': ponto.nome,
        'marker': Marker(
          point: LatLng((ponto.latitude), (ponto.longitude)
          ),
          builder: (_) => Icon(iconData, color: markerColor, size: 30),
        ),
      };
    }).toList();
  }

  // Gera marcadores estáticos (hotéis e restaurantes)
  List<Map<String, dynamic>> _generateStaticMarkers(
      List<Map<String, dynamic>> locations, String type, Color color) {
    return locations.map((location) {
      IconData icon = type == 'hotel'
          ? Icons.hotel
          : type == 'restaurante'
              ? Icons.restaurant
              : Icons.location_on;

      return {
        'type': type,
        'nome': location['nome'],
        'marker': Marker(
          point: LatLng(location['lat'], location['lng']),
          builder: (_) => Icon(icon, color: color, size: 30),
        ),
      };
    }).toList();
  }

  // Retorna todos os marcadores filtrados
  List<Marker> getFilteredMarkers(
      List<PontosTuristicos> apiPoints, String selectedFilter) {
    List<Map<String, dynamic>> allMarkers = [];

    allMarkers.addAll(_generateMarkersFromApi(apiPoints));
    allMarkers.addAll(_generateStaticMarkers(hotel, 'hotel', Colors.blue));
    allMarkers.addAll(_generateStaticMarkers(restaurant, 'restaurante', Colors.green));

    if (selectedFilter == 'Todos') {
      return allMarkers.map((m) => m['marker'] as Marker).toList();
    } else {
      return allMarkers
          .where((marker) =>
              marker['type'].toString().toLowerCase() ==
              selectedFilter.toLowerCase())
          .map((m) => m['marker'] as Marker)
          .toList();
    }
  }

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

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
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
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Todos', child: Text('Todos')),
              const PopupMenuItem(value: 'turístico', child: Text('Turísticos')),
              const PopupMenuItem(value: 'histórico', child: Text('Históricos')),
              const PopupMenuItem(value: 'hotel', child: Text('Hotéis')),
              const PopupMenuItem(value: 'restaurante', child: Text('Restaurantes')),
              const PopupMenuItem(
                value: 'Sair',
                child: Text('Sair', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<PontosTuristicos>>(
        future: futurePontos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<PontosTuristicos> pontos = snapshot.data!;
            return FlutterMap(
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
                MarkerLayer(
                  markers: getFilteredMarkers(pontos, selectedFilter),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar pontos: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(parnaibaLocation, 13);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, size: 30, color: Colors.white),
      ),
    );
  }
}