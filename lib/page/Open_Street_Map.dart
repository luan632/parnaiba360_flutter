import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

import 'package:parnaiba360_flutter/core/service/auth/auth_service.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_mock_service.dart';
import 'package:parnaiba360_flutter/core/models/pontos_turisticos.dart';
import 'package:parnaiba360_flutter/core/service/api_services.dart';

// Constantes para cores e estilos
class AppColors {
  static const Color primary = Color(0xFF1A2980);
  static const Color secondary = Color(0xFF26D0CE);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.2,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

// Modelo de Usuário para armazenar dados do perfil
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? fotoUrl;
  final String? telefone;
  final String? bio;
  final DateTime dataRegistro;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.fotoUrl,
    this.telefone,
    this.bio,
    required this.dataRegistro,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      fotoUrl: json['fotoUrl'],
      telefone: json['telefone'],
      bio: json['bio'],
      dataRegistro: DateTime.parse(json['dataRegistro']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'fotoUrl': fotoUrl,
      'telefone': telefone,
      'bio': bio,
      'dataRegistro': dataRegistro.toIso8601String(),
    };
  }
  
  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    String? fotoUrl,
    String? telefone,
    String? bio,
    DateTime? dataRegistro,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      telefone: telefone ?? this.telefone,
      bio: bio ?? this.bio,
      dataRegistro: dataRegistro ?? this.dataRegistro,
    );
  }
}

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

class LocalizacaoModel {
  final String nome;
  final double lat;
  final double lng;
  final String descricao;
  final String endereco;
  final String imagem;
  final List<Comentario> comentarios;
  final String categoria;
  final int preco;

  LocalizacaoModel({
    required this.nome,
    required this.lat,
    required this.lng,
    required this.descricao,
    required this.endereco,
    required this.imagem,
    required this.comentarios,
    required this.categoria,
    required this.preco,
  });

  factory LocalizacaoModel.fromJson(Map<String, dynamic> json) {
    return LocalizacaoModel(
      nome: json['nome'],
      lat: json['lat'],
      lng: json['lng'],
      descricao: json['descricao'],
      endereco: json['endereco'],
      imagem: json['imagem'],
      comentarios: (json['comentarios'] as List<dynamic>?)
          ?.map((comment) => Comentario.fromJson(comment))
          .toList() ?? [],
      categoria: json['categoria'],
      preco: json['preco'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'lat': lat,
      'lng': lng,
      'descricao': descricao,
      'endereco': endereco,
      'imagem': imagem,
      'comentarios': comentarios.map((comment) => comment.toJson()).toList(),
      'categoria': categoria,
      'preco': preco,
    };
  }
}

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({super.key});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LatLng parnaibaLocation = const LatLng(-2.9038, -41.7767);
  String selectedFilter = 'Ponto Turístico';
  final AuthService _authService = AuthMockService();

  late Future<List<PontosTuristicos>> futurePontos;

  // Controladores para filtros
  final TextEditingController _searchController = TextEditingController();
  bool _showFiltersPanel = false;

  // Controladores para perfil e feedback
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  // Dados do usuário atual
  Usuario? _usuarioAtual;
  File? _imagemPerfil;
  final ImagePicker _imagePicker = ImagePicker();
  bool _editandoPerfil = false;
  
  // Animação
  late AnimationController _animationController;
  late Animation<double> _filtersPanelAnimation;

  // Dados das localizações
  final List<LocalizacaoModel> _pontosTuristicos = [
    LocalizacaoModel(
      nome: "Praça Mandu Ladino",
      lat: -2.902870,
      lng: -41.768831,
      descricao: "A Praça Mandu Ladino é um espaço histórico da cidade.",
      endereco: "Rua Paul Harris - Nossa Sra. de Fátima, Parnaíba - PI, 64202-400",
      imagem: 'assets/images/quadrilhodromo.jpg',
      comentarios: [],
      categoria: 'Ponto Turístico',
      preco: 0,
    ),
    // ... outros pontos turísticos
  ];

  final List<LocalizacaoModel> _hoteis = [
    LocalizacaoModel(
      nome: 'Hotel Cívico',
      lat: -2.903465,
      lng: -41.773410,
      descricao: "Hotel moderno e bem localizado no centro comercial.",
      endereco: "Av. Chagas Rodrigues, 474 - Centro, Parnaíba - PI, 64200-490",
      imagem: 'assets/images/Hotel-Civico.jpg',
      comentarios: [],
      categoria: 'Hotel',
      preco: 3,
    ),
    // ... outros hotéis
  ];

  final List<LocalizacaoModel> _restaurantes = [
    LocalizacaoModel(
      nome: 'Restaurante Mangata',
      lat: -2.910322,
      lng: -41.744839,
      descricao: "Comida regional e pratos internacionais.",
      endereco: "Av. São Sebastião, 3900 - Frei Higino, Parnaíba - PI, 64207-005",
      imagem: 'assets/images/Mangata.jpg',
      comentarios: [],
      categoria: 'Restaurante',
      preco: 3,
    ),
    // ... outros restaurantes
  ];

  @override
  void initState() {
    super.initState();
    futurePontos = ApiServices().getPontos();
    _carregarDadosUsuario();
    
    // Configuração da animação
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _filtersPanelAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _bioController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  // Carrega dados do usuário
  void _carregarDadosUsuario() {
    if (_authService.currentUser != null) {
      // Simulação - em um app real, buscaria de um serviço ou banco de dados
      setState(() {
        _usuarioAtual = Usuario(
          id: _authService.currentUser!.id,
          nome: _authService.currentUser?.displayName ?? 'Usuário',
          email: _authService.currentUser?.email ?? '',
          telefone: '(86) 99999-9999', // Valor padrão
          bio: 'Amante de viagens e explorar novos lugares!',
          dataRegistro: DateTime.now(),
        );
        
        _nomeController.text = _usuarioAtual!.nome;
        _emailController.text = _usuarioAtual!.email;
        _telefoneController.text = _usuarioAtual!.telefone ?? '';
        _bioController.text = _usuarioAtual!.bio ?? '';
      });
    }
  }

  // Selecionar imagem da galeria
  Future<void> _selecionarImagem() async {
    if (kIsWeb) {
      // Implementação específica para web se necessário
      return;
    }
    
    final XFile? imagemSelecionada = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (imagemSelecionada != null) {
      setState(() {
        _imagemPerfil = File(imagemSelecionada.path);
      });
    }
  }

  // Tirar foto com a câmera
  Future<void> _tirarFoto() async {
    if (kIsWeb) {
      // Implementação específica para web se necessário
      return;
    }
    
    final XFile? fotoTirada = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (fotoTirada != null) {
      setState(() {
        _imagemPerfil = File(fotoTirada.path);
      });
    }
  }

  // Salvar alterações do perfil
  void _salvarPerfil() {
    if (_usuarioAtual != null) {
      setState(() {
        _usuarioAtual = _usuarioAtual!.copyWith(
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
          bio: _bioController.text.isNotEmpty ? _bioController.text : null,
        );
        
        _editandoPerfil = false;
      });
      
      // Aqui você implementaria a lógica para salvar no backend
      if (kDebugMode) {
        print('Perfil salvo: ${_usuarioAtual!.toJson()}');
      }
    }
  }

  // Combina todas as localizações
  List<LocalizacaoModel> get allLocations {
    return [
      ..._pontosTuristicos,
      ..._hoteis,
      ..._restaurantes,
    ];
  }

  // Gera marcadores dinamicamente
  List<Marker> _generateMarkers(List<LocalizacaoModel> locations, String type, Color color) {
    return locations.map((location) {
      return Marker(
        point: LatLng(location.lat, location.lng),
        width: 50,
        height: 50,
        anchorPos: AnchorPos.align(AnchorAlign.top),
        builder: (_) => GestureDetector(
          onTap: () {
            _showMarkerInfo(context, location);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              type == 'Ponto Turístico'
                  ? Icons.landscape
                  : type == 'Hotel'
                      ? Icons.hotel
                      : Icons.restaurant,
              color: color,
              size: 28,
            ),
          ),
        ),
      );
    }).toList();
  }

  // Exibe informações do marcador em diálogo
  void _showMarkerInfo(BuildContext context, LocalizacaoModel info) {
    final TextEditingController _comentarioController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => MarkerInfoDialog(
        info: info,
        comentarioController: _comentarioController,
        authService: _authService,
        onCommentAdded: (novoComentario) {
          setState(() {
            info.comentarios.insert(0, novoComentario);
          });
        },
      ),
    );
  }

  // Retorna marcadores filtrados
  List<Marker> getFilteredMarkers() {
    List<Marker> allMarkers = [];
    allMarkers.addAll(_generateMarkers(_pontosTuristicos, 'Ponto Turístico', Colors.red));
    allMarkers.addAll(_generateMarkers(_hoteis, 'Hotel', Colors.blue));
    allMarkers.addAll(_generateMarkers(_restaurantes, 'Restaurante', Colors.green));

    // Aplicar filtros
    List<Marker> filteredMarkers = allMarkers;

    // Filtro por texto de busca
    if (_searchController.text.isNotEmpty) {
      // Este filtro não funcionará corretamente pois os marcadores não contêm informações
      // Para implementar isso corretamente, precisaríamos de uma estrutura diferente
    }
    
    return filteredMarkers;
  }

  // Aplica filtro ou abre perfil
  void _applyFilter(String? filter) {
    if (filter != null) {
      if (filter == 'Sair') {
        _confirmLogout(context);
      } else if (filter == 'Perfil') {
        _showProfileDialog(context);
      } else {
        setState(() {
          selectedFilter = filter;
        });
      }
    }
  }

  // Mostra diálogo de perfil
  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PerfilDialog(
        usuarioAtual: _usuarioAtual,
        imagemPerfil: _imagemPerfil,
        editandoPerfil: _editandoPerfil,
        nomeController: _nomeController,
        emailController: _emailController,
        telefoneController: _telefoneController,
        bioController: _bioController,
        feedbackController: _feedbackController,
        onEditProfile: () {
          setState(() {
            _editandoPerfil = true;
          });
        },
        onSaveProfile: _salvarPerfil,
        onCancelEdit: () {
          setState(() {
            _editandoPerfil = false;
            // Restaurar valores originais
            _nomeController.text = _usuarioAtual?.nome ?? '';
            _emailController.text = _usuarioAtual?.email ?? '';
            _telefoneController.text = _usuarioAtual?.telefone ?? '';
            _bioController.text = _usuarioAtual?.bio ?? '';
          });
        },
        onSelectImage: _selecionarImagem,
        onTakePhoto: _tirarFoto,
        onSendFeedback: _sendFeedback,
      ),
    );
  }

  // Diálogo para escolher fonte da imagem
  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher fonte da imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _selecionarImagem();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _tirarFoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Envia feedback (simulação)
  void _sendFeedback() {
    if (kDebugMode) {
      print('Feedback enviado: ${_feedbackController.text}');
    }
    _feedbackController.clear();
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
            onPressed: () => Navigator.of(context).pop(false),
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
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // Widget para o painel de filtros
  Widget _buildFiltersPanel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: _showFiltersPanel ? 80 : -250,
      left: 20,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: selectedFilter == 'Todos',
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = selected ? 'Todos' : selectedFilter;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Pontos Turísticos'),
                    selected: selectedFilter == 'Ponto Turístico',
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = selected ? 'Ponto Turístico' : selectedFilter;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Hotéis'),
                    selected: selectedFilter == 'Hotel',
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = selected ? 'Hotel' : selectedFilter;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Restaurantes'),
                    selected: selectedFilter == 'Restaurante',
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = selected ? 'Restaurante' : selectedFilter;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        selectedFilter = 'Todos';
                      });
                    },
                    child: const Text('Limpar Filtros'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.accent, size: 28),
            const SizedBox(width: 10),
            Text(
              'Parnaíba360',
              style: AppTextStyles.headline1,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFiltersPanel = !_showFiltersPanel;
                if (_showFiltersPanel) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Ponto Turístico',
                child: Row(
                  children: [
                    Icon(Icons.landscape, color: Colors.red),
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
                    Icon(Icons.restaurant, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Restaurantes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Perfil',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.purple),
                    SizedBox(width: 10),
                    Text('Perfil'),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: parnaibaLocation,
                zoom: 13,
                minZoom: 10,
                maxZoom: 18,
                onPositionChanged: (MapPosition position, bool hasGesture) {
                  if (hasGesture) {
                    // O usuário moveu o mapa manualmente
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.parnaiba360',
                ),
                CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      color: AppColors.primary,
                      child: const Icon(Icons.person_pin_circle, color: Colors.white),
                    ),
                    markerSize: const Size(40, 40),
                    accuracyCircleColor: AppColors.primary.withOpacity(0.3),
                    headingSectorColor: AppColors.primary,
                    headingSectorRadius: 60,
                    showAccuracyCircle: true,
                    showHeadingSector: true,
                  ),
                  turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                ),
                MarkerLayer(markers: getFilteredMarkers()),
              ],
            ),
            // Botão para centralizar na localização atual
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      _mapController.move(parnaibaLocation, 13);
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.my_location,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _showFiltersPanel = !_showFiltersPanel;
                        if (_showFiltersPanel) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
                      });
                    },
                    backgroundColor: _showFiltersPanel ? Colors.orange : AppColors.primary,
                    mini: true,
                    child: Icon(
                      _showFiltersPanel ? Icons.close : Icons.filter_list,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            _buildFiltersPanel(),
          ],
        ),
      ),
    );
  }
}

// Diálogo de informações do marcador
class MarkerInfoDialog extends StatefulWidget {
  final LocalizacaoModel info;
  final TextEditingController comentarioController;
  final AuthService authService;
  final Function(Comentario) onCommentAdded;

  const MarkerInfoDialog({
    super.key,
    required this.info,
    required this.comentarioController,
    required this.authService,
    required this.onCommentAdded,
  });

  @override
  State<MarkerInfoDialog> createState() => _MarkerInfoDialogState();
}

class _MarkerInfoDialogState extends State<MarkerInfoDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.info.imagem.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.info.imagem,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.info.nome,
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: 8),
            if (widget.info.preco > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '\$' * widget.info.preco,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              widget.info.descricao,
              style: AppTextStyles.bodyText1,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.info.endereco,
                    style: AppTextStyles.bodyText2,
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
            
            if (widget.info.comentarios.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Nenhum comentário ainda. Seja o primeiro a comentar!'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.info.comentarios.length,
                itemBuilder: (context, index) {
                  final comentario = widget.info.comentarios[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
              controller: widget.comentarioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deixe seu comentário',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (widget.comentarioController.text.trim().isNotEmpty) {
                      final novoComentario = Comentario(
                        usuario: widget.authService.currentUser?.displayName ?? 'Anônimo',
                        texto: widget.comentarioController.text.trim(),
                        data: DateTime.now(),
                      );
                      
                      widget.onCommentAdded(novoComentario);
                      widget.comentarioController.clear();
                      
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Fechar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Diálogo de perfil do usuário
class PerfilDialog extends StatefulWidget {
  final Usuario? usuarioAtual;
  final File? imagemPerfil;
  final bool editandoPerfil;
  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController telefoneController;
  final TextEditingController bioController;
  final TextEditingController feedbackController;
  final VoidCallback onEditProfile;
  final VoidCallback onSaveProfile;
  final VoidCallback onCancelEdit;
  final VoidCallback onSelectImage;
  final VoidCallback onTakePhoto;
  final VoidCallback onSendFeedback;

  const PerfilDialog({
    super.key,
    required this.usuarioAtual,
    required this.imagemPerfil,
    required this.editandoPerfil,
    required this.nomeController,
    required this.emailController,
    required this.telefoneController,
    required this.bioController,
    required this.feedbackController,
    required this.onEditProfile,
    required this.onSaveProfile,
    required this.onCancelEdit,
    required this.onSelectImage,
    required this.onTakePhoto,
    required this.onSendFeedback,
  });

  @override
  State<PerfilDialog> createState() => _PerfilDialogState();
}

class _PerfilDialogState extends State<PerfilDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.editandoPerfil ? 'Editar Perfil' : 'Meu Perfil',
                  style: AppTextStyles.headline2,
                ),
                if (!widget.editandoPerfil)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: widget.onEditProfile,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  backgroundImage: widget.imagemPerfil != null
                      ? FileImage(widget.imagemPerfil!) as ImageProvider
                      : (widget.usuarioAtual?.fotoUrl != null
                          ? NetworkImage(widget.usuarioAtual!.fotoUrl!)
                          : const AssetImage('assets/images/default_avatar.png')) as ImageProvider,
                ),
                if (widget.editandoPerfil)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Escolher fonte da imagem'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Galeria'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      widget.onSelectImage();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Câmera'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      widget.onTakePhoto();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (widget.editandoPerfil) ...[
              TextField(
                controller: widget.nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.telefoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else ...[
              Text(
                widget.usuarioAtual?.nome ?? 'Usuário',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.usuarioAtual?.email ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (widget.usuarioAtual?.telefone != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.usuarioAtual!.telefone!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              if (widget.usuarioAtual?.bio != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.usuarioAtual!.bio!,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Membro desde ${widget.usuarioAtual?.dataRegistro.day}/${widget.usuarioAtual?.dataRegistro.month}/${widget.usuarioAtual?.dataRegistro.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              'Enviar Feedback',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Digite seu feedback aqui...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.editandoPerfil)
                  TextButton(
                    onPressed: widget.onCancelEdit,
                    child: const Text('Cancelar'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (widget.editandoPerfil) {
                      widget.onSaveProfile();
                    }
                    
                    if (widget.feedbackController.text.isNotEmpty) {
                      widget.onSendFeedback();
                    }
                    
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.editandoPerfil 
                            ? 'Perfil atualizado com sucesso!' 
                            : 'Feedback enviado com sucesso!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(widget.editandoPerfil ? 'Salvar' : 'Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}