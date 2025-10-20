import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:parnaiba360_flutter/core/service/auth/auth_service.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_mock_service.dart';
import 'package:parnaiba360_flutter/core/models/pontos_turisticos.dart';
import 'package:parnaiba360_flutter/core/service/api_services.dart';

// ========== CONSTANTES E CONFIGURAÇÕES ==========
class AppColors {
  static const Color primary = Color(0xFF1A2980);
  static const Color secondary = Color(0xFF26D0CE);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color cardShadow = Color(0x1A000000);
  
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x001A2980), Color(0xCC1A2980)],
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
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
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
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 48.0;
}

// ========== MODELOS APRIMORADOS ==========
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? fotoUrl;
  final String? telefone;
  final String? bio;
  final DateTime dataRegistro;
  final List<String> favoritos;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.fotoUrl,
    this.telefone,
    this.bio,
    required this.dataRegistro,
    this.favoritos = const [],
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
      favoritos: List<String>.from(json['favoritos'] ?? []),
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
      'favoritos': favoritos,
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
    List<String>? favoritos,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      telefone: telefone ?? this.telefone,
      bio: bio ?? this.bio,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      favoritos: favoritos ?? this.favoritos,
    );
  }
}

class Comentario {
  final String usuarioId;
  final String usuarioNome;
  final String texto;
  final DateTime data;
  final double? avaliacao;

  Comentario({
    required this.usuarioId,
    required this.usuarioNome,
    required this.texto,
    required this.data,
    this.avaliacao,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      usuarioId: json['usuarioId'],
      usuarioNome: json['usuarioNome'],
      texto: json['texto'],
      data: DateTime.parse(json['data']),
      avaliacao: json['avaliacao']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'usuarioNome': usuarioNome,
      'texto': texto,
      'data': data.toIso8601String(),
      'avaliacao': avaliacao,
    };
  }
}

class LocalizacaoModel {
  final String id;
  final String nome;
  final double lat;
  final double lng;
  final String descricao;
  final String endereco;
  final String imagem;
  final List<Comentario> comentarios;
  final String categoria;
  final int preco;
  final double avaliacaoMedia;
  final int totalAvaliacoes;
  final List<String> fotos;
  final String telefone;
  final String site;
  final List<String> horariosFuncionamento;
  final List<String> tags;

  LocalizacaoModel({
    required this.id,
    required this.nome,
    required this.lat,
    required this.lng,
    required this.descricao,
    required this.endereco,
    required this.imagem,
    required this.comentarios,
    required this.categoria,
    required this.preco,
    this.avaliacaoMedia = 0.0,
    this.totalAvaliacoes = 0,
    this.fotos = const [],
    this.telefone = '',
    this.site = '',
    this.horariosFuncionamento = const [],
    this.tags = const [],
  });

  factory LocalizacaoModel.fromJson(Map<String, dynamic> json) {
    return LocalizacaoModel(
      id: json['id'],
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
      avaliacaoMedia: json['avaliacaoMedia']?.toDouble() ?? 0.0,
      totalAvaliacoes: json['totalAvaliacoes'] ?? 0,
      fotos: List<String>.from(json['fotos'] ?? []),
      telefone: json['telefone'] ?? '',
      site: json['site'] ?? '',
      horariosFuncionamento: List<String>.from(json['horariosFuncionamento'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'lat': lat,
      'lng': lng,
      'descricao': descricao,
      'endereco': endereco,
      'imagem': imagem,
      'comentarios': comentarios.map((comment) => comment.toJson()).toList(),
      'categoria': categoria,
      'preco': preco,
      'avaliacaoMedia': avaliacaoMedia,
      'totalAvaliacoes': totalAvaliacoes,
      'fotos': fotos,
      'telefone': telefone,
      'site': site,
      'horariosFuncionamento': horariosFuncionamento,
      'tags': tags,
    };
  }
}

// ========== WIDGETS PERSONALIZADOS ==========
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool elevated;

  const CustomCard({
    super.key,
    required this.child,
    this.margin,
    this.onTap,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: elevated ? [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: child,
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.chip.copyWith(
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final bool showReviews;

  const RatingWidget({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.showReviews = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor() ? Icons.star : Icons.star_border,
            color: AppColors.accent,
            size: 16,
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.bodyText2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showReviews && totalReviews > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($totalReviews)',
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }
}

// ========== TELA PRINCIPAL APRIMORADA ==========
class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({super.key});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LatLng parnaibaLocation = const LatLng(-2.9038, -41.7767);
  String selectedFilter = 'Todos';
  final AuthService _authService = AuthMockService();

  late Future<List<PontosTuristicos>> futurePontos;

  // Controladores
  final TextEditingController _searchController = TextEditingController();
  bool _showFiltersPanel = false;
  bool _showBottomSheet = false;

  // Controladores para perfil
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  // Dados do usuário
  Usuario? _usuarioAtual;
  File? _imagemPerfil;
  final ImagePicker _imagePicker = ImagePicker();
  bool _editandoPerfil = false;
  
  // Animações
  late AnimationController _animationController;
  late Animation<double> _filtersAnimation;

  // Dados de exemplo aprimorados
  final List<LocalizacaoModel> _pontosTuristicos = [
    LocalizacaoModel(
      id: '1',
      nome: "Praça Mandu Ladino",
      lat: -2.902870,
      lng: -41.768831,
      descricao: "A Praça Mandu Ladino é um espaço histórico da cidade, conhecido por sua arquitetura colonial e eventos culturais.",
      endereco: "Rua Paul Harris - Nossa Sra. de Fátima, Parnaíba - PI, 64202-400",
      imagem: 'assets/images/quadrilhodromo.jpg',
      comentarios: [],
      categoria: 'Ponto Turístico',
      preco: 0,
      avaliacaoMedia: 4.5,
      totalAvaliacoes: 127,
      telefone: '(86) 3322-1234',
      horariosFuncionamento: ['Segunda a Domingo: 06:00 - 22:00'],
      tags: ['Histórico', 'Cultural', 'Gratuito'],
    ),
    LocalizacaoModel(
      id: '4',
      nome: "Porto das Barcas",
      lat: -2.907778,
      lng: -41.776111,
      descricao: "Complexo histórico que foi o primeiro porto da cidade, hoje abriga restaurantes, lojas e espaços culturais.",
      endereco: "Rua Lívio Lopes - Centro, Parnaíba - PI, 64200-020",
      imagem: 'assets/images/porto_barcas.jpg',
      comentarios: [],
      categoria: 'Ponto Turístico',
      preco: 0,
      avaliacaoMedia: 4.8,
      totalAvaliacoes: 245,
      telefone: '(86) 3321-4567',
      horariosFuncionamento: ['Terça a Domingo: 10:00 - 22:00'],
      tags: ['Histórico', 'Cultural', 'Gastronomia'],
    ),
  ];

  final List<LocalizacaoModel> _hoteis = [
    LocalizacaoModel(
      id: '2',
      nome: 'Hotel Cívico',
      lat: -2.903465,
      lng: -41.773410,
      descricao: "Hotel moderno e bem localizado no centro comercial, com piscina, Wi-Fi gratuito e café da manhã incluso.",
      endereco: "Av. Chagas Rodrigues, 474 - Centro, Parnaíba - PI, 64200-490",
      imagem: 'assets/images/Hotel-Civico.jpg',
      comentarios: [],
      categoria: 'Hotel',
      preco: 3,
      avaliacaoMedia: 4.2,
      totalAvaliacoes: 89,
      telefone: '(86) 3315-6789',
      site: 'www.hotelcivico.com.br',
      tags: ['Wi-Fi', 'Piscina', 'Estacionamento'],
    ),
    LocalizacaoModel(
      id: '5',
      nome: 'Pousada do Rio',
      lat: -2.901234,
      lng: -41.772345,
      descricao: "Pousada charmosa às margens do Rio Igaraçu, com vista panorâmica e atmosfera acolhedora.",
      endereco: "Rua do Rio, 123 - Centro, Parnaíba - PI, 64200-000",
      imagem: 'assets/images/pousada_rio.jpg',
      comentarios: [],
      categoria: 'Hotel',
      preco: 2,
      avaliacaoMedia: 4.4,
      totalAvaliacoes: 67,
      telefone: '(86) 3322-9876',
      site: 'www.pousadadorio.com.br',
      tags: ['Vista Rio', 'Familiar', 'Café da Manhã'],
    ),
  ];

  final List<LocalizacaoModel> _restaurantes = [
    LocalizacaoModel(
      id: '3',
      nome: 'Restaurante Mangata',
      lat: -2.910322,
      lng: -41.744839,
      descricao: "Comida regional e pratos internacionais em ambiente sofisticado. Especialidade em frutos do mar.",
      endereco: "Av. São Sebastião, 3900 - Frei Higino, Parnaíba - PI, 64207-005",
      imagem: 'assets/images/Mangata.jpg',
      comentarios: [],
      categoria: 'Restaurante',
      preco: 3,
      avaliacaoMedia: 4.7,
      totalAvaliacoes: 203,
      telefone: '(86) 3321-5555',
      horariosFuncionamento: ['Terça a Domingo: 11:00 - 23:00'],
      tags: ['Frutos do Mar', 'Regional', 'Sofisticado'],
    ),
    LocalizacaoModel(
      id: '6',
      nome: 'Cantinho do Sabor',
      lat: -2.908765,
      lng: -41.771234,
      descricao: "Comida caseira e regional em ambiente familiar. Pratos típicos do Piauí com preços acessíveis.",
      endereco: "Rua Simplício Mendes, 456 - Centro, Parnaíba - PI, 64200-100",
      imagem: 'assets/images/cantinho_sabor.jpg',
      comentarios: [],
      categoria: 'Restaurante',
      preco: 1,
      avaliacaoMedia: 4.3,
      totalAvaliacoes: 156,
      telefone: '(86) 3314-2233',
      horariosFuncionamento: ['Segunda a Sábado: 11:00 - 15:00', '18:00 - 22:00'],
      tags: ['Caseira', 'Regional', 'Familiar'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    futurePontos = ApiServices().getPontos();
    _carregarDadosUsuario();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _filtersAnimation = CurvedAnimation(
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

  void _carregarDadosUsuario() {
    if (_authService.currentUser != null) {
      setState(() {
        _usuarioAtual = Usuario(
          id: _authService.currentUser!.id,
          nome: _authService.currentUser?.displayName ?? 'Usuário',
          email: _authService.currentUser?.email ?? '',
          telefone: '(86) 99999-9999',
          bio: 'Amante de viagens e explorar novos lugares!',
          dataRegistro: DateTime.now(),
          favoritos: ['1', '3'],
        );
        
        _nomeController.text = _usuarioAtual!.nome;
        _emailController.text = _usuarioAtual!.email;
        _telefoneController.text = _usuarioAtual!.telefone ?? '';
        _bioController.text = _usuarioAtual!.bio ?? '';
      });
    }
  }

  Future<void> _selecionarImagem() async {
    if (kIsWeb) return;
    
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

  Future<void> _tirarFoto() async {
    if (kIsWeb) return;
    
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
      
      if (kDebugMode) {
        print('Perfil salvo: ${_usuarioAtual!.toJson()}');
      }
    }
  }

  List<LocalizacaoModel> get allLocations => [..._pontosTuristicos, ..._hoteis, ..._restaurantes];

  List<Marker> getFilteredMarkers() {
    List<LocalizacaoModel> filteredLocations = [];
    
    if (selectedFilter == 'Todos') {
      filteredLocations = allLocations;
    } else if (selectedFilter == 'Ponto Turístico') {
      filteredLocations = _pontosTuristicos;
    } else if (selectedFilter == 'Hotel') {
      filteredLocations = _hoteis;
    } else if (selectedFilter == 'Restaurante') {
      filteredLocations = _restaurantes;
    }
    
    if (_searchController.text.isNotEmpty) {
      filteredLocations = filteredLocations.where((location) {
        return location.nome.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               location.descricao.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               location.tags.any((tag) => tag.toLowerCase().contains(_searchController.text.toLowerCase()));
      }).toList();
    }
    
    return filteredLocations.map((location) {
      Color color;
      IconData icon;
      
      switch (location.categoria) {
        case 'Ponto Turístico':
          color = Colors.red;
          icon = Icons.landscape;
          break;
        case 'Hotel':
          color = Colors.blue;
          icon = Icons.hotel;
          break;
        case 'Restaurante':
          color = Colors.green;
          icon = Icons.restaurant;
          break;
        default:
          color = Colors.grey;
          icon = Icons.location_on;
      }
      
      final isFavorite = _usuarioAtual?.favoritos.contains(location.id) ?? false;
      
      return Marker(
        point: LatLng(location.lat, location.lng),
        width: 60,
        height: 60,
        anchorPos: AnchorPos.align(AnchorAlign.top),
        builder: (_) => GestureDetector(
          onTap: () {
            _showMarkerInfo(context, location);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: color, width: 3),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                if (isFavorite)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showMarkerInfo(BuildContext context, LocalizacaoModel info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarkerInfoBottomSheet(
        info: info,
        authService: _authService,
        usuarioAtual: _usuarioAtual,
        onCommentAdded: (novoComentario) {
          setState(() {
            info.comentarios.insert(0, novoComentario);
          });
        },
        onToggleFavorite: (localId) {
          setState(() {
            if (_usuarioAtual != null) {
              final favoritos = List<String>.from(_usuarioAtual!.favoritos);
              if (favoritos.contains(localId)) {
                favoritos.remove(localId);
              } else {
                favoritos.add(localId);
              }
              _usuarioAtual = _usuarioAtual!.copyWith(favoritos: favoritos);
            }
          });
        },
      ),
    );
  }

  void _applyFilter(String? filter) {
    if (filter != null) {
      if (filter == 'Sair') {
        _confirmLogout(context);
      } else if (filter == 'Perfil') {
        _showProfileDialog(context);
      } else if (filter == 'Favoritos') {
        _showFavorites(context);
      } else {
        setState(() {
          selectedFilter = filter;
          _showFiltersPanel = false;
          _animationController.reverse();
        });
      }
    }
  }

  void _showFavorites(BuildContext context) {
    final favoritos = allLocations.where((loc) => 
      _usuarioAtual?.favoritos.contains(loc.id) ?? false
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FavoritesBottomSheet(
        favoritos: favoritos,
        onLocationTap: (location) {
          Navigator.pop(context);
          _mapController.move(LatLng(location.lat, location.lng), 15);
          _showMarkerInfo(context, location);
        },
      ),
    );
  }

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

  void _sendFeedback() {
    if (kDebugMode) {
      print('Feedback enviado: ${_feedbackController.text}');
    }
    _feedbackController.clear();
  }

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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Widget _buildFiltersPanel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      top: _showFiltersPanel ? 80 : -300,
      left: 20,
      right: 20,
      child: ScaleTransition(
        scale: _filtersAnimation,
        child: Material(
          elevation: 16,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtrar Locais',
                      style: AppTextStyles.headline1.copyWith(fontSize: 20),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _showFiltersPanel = false;
                          _animationController.reverse();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, descrição ou tags...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Categorias',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCategoryChip('Todos', Colors.white),
                    _buildCategoryChip('Ponto Turístico', Colors.red),
                    _buildCategoryChip('Hotel', Colors.blue),
                    _buildCategoryChip('Restaurante', Colors.green),
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
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Limpar Filtros'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, Color color) {
    return CategoryChip(
      label: category,
      selected: selectedFilter == category,
      onTap: () {
        setState(() {
          selectedFilter = category;
        });
      },
      color: color,
    );
  }

  Widget _buildLocationCard(LocalizacaoModel location) {
    final isFavorite = _usuarioAtual?.favoritos.contains(location.id) ?? false;
    
    return CustomCard(
      onTap: () {
        _mapController.move(LatLng(location.lat, location.lng), 15);
        _showMarkerInfo(context, location);
      },
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Imagem
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              image: DecorationImage(
                image: AssetImage(location.imagem),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        location.nome,
                        style: AppTextStyles.headline3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_usuarioAtual != null) {
                            final favoritos = List<String>.from(_usuarioAtual!.favoritos);
                            if (favoritos.contains(location.id)) {
                              favoritos.remove(location.id);
                            } else {
                              favoritos.add(location.id);
                            }
                            _usuarioAtual = _usuarioAtual!.copyWith(favoritos: favoritos);
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location.descricao,
                  style: AppTextStyles.bodyText2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingWidget(
                      rating: location.avaliacaoMedia,
                      totalReviews: location.totalAvaliacoes,
                    ),
                    const Spacer(),
                    if (location.preco > 0)
                      Text(
                        '\$' * location.preco,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (!_showBottomSheet) return const SizedBox.shrink();
    
    final filteredLocations = allLocations.where((location) {
      if (selectedFilter == 'Todos') return true;
      return location.categoria == selectedFilter;
    }).toList();
    
    if (_searchController.text.isNotEmpty) {
      filteredLocations.retainWhere((location) {
        return location.nome.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               location.descricao.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               location.tags.any((tag) => tag.toLowerCase().contains(_searchController.text.toLowerCase()));
      });
    }
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: _showBottomSheet ? 300 : 0,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
            topRight: Radius.circular(AppDimensions.borderRadiusLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Locais Próximos (${filteredLocations.length})',
                    style: AppTextStyles.headline2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showBottomSheet = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Lista de locais
            Expanded(
              child: filteredLocations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum local encontrado',
                            style: AppTextStyles.bodyText1.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredLocations.length,
                      itemBuilder: (context, index) {
                        return _buildLocationCard(filteredLocations[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.explore, color: AppColors.accent, size: 28),
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
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              setState(() {
                _showBottomSheet = !_showBottomSheet;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Favoritos',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Favoritos'),
                  ],
                ),
              ),
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
              const PopupMenuDivider(),
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
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            // Mapa
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: parnaibaLocation,
                zoom: 13,
                minZoom: 10,
                maxZoom: 18,
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
            
            // Painel de Filtros
            _buildFiltersPanel(),
            
            // Bottom Sheet com lista de locais
            _buildBottomSheet(),
            
            // Botões de Ação
            Positioned(
              bottom: _showBottomSheet ? 320 : 20,
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    backgroundColor: _showFiltersPanel ? AppColors.accent : AppColors.primary,
                    mini: true,
                    child: Icon(
                      _showFiltersPanel ? Icons.close : Icons.filter_list,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== BOTTOM SHEET DE INFORMAÇÕES DO MARCADOR ==========
class MarkerInfoBottomSheet extends StatefulWidget {
  final LocalizacaoModel info;
  final AuthService authService;
  final Usuario? usuarioAtual;
  final Function(Comentario) onCommentAdded;
  final Function(String) onToggleFavorite;

  const MarkerInfoBottomSheet({
    super.key,
    required this.info,
    required this.authService,
    required this.usuarioAtual,
    required this.onCommentAdded,
    required this.onToggleFavorite,
  });

  @override
  State<MarkerInfoBottomSheet> createState() => _MarkerInfoBottomSheetState();
}

class _MarkerInfoBottomSheetState extends State<MarkerInfoBottomSheet> {
  final TextEditingController _comentarioController = TextEditingController();
  double _avaliacao = 0.0;

  @override
  Widget build(BuildContext context) {
    final isFavorite = widget.usuarioAtual?.favoritos.contains(widget.info.id) ?? false;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
          topRight: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com imagem e informações básicas
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                          image: DecorationImage(
                            image: AssetImage(widget.info.imagem),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              widget.onToggleFavorite(widget.info.id);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppColors.secondaryGradient,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(AppDimensions.borderRadius),
                              bottomRight: Radius.circular(AppDimensions.borderRadius),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.info.nome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RatingWidget(
                                rating: widget.info.avaliacaoMedia,
                                totalReviews: widget.info.totalAvaliacoes,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Informações principais
                  Row(
                    children: [
                      _buildInfoChip(widget.info.categoria, Icons.category),
                      if (widget.info.preco > 0) ...[
                        const SizedBox(width: 8),
                        _buildInfoChip('\$' * widget.info.preco, Icons.attach_money),
                      ],
                      const Spacer(),
                      if (widget.info.telefone.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.phone, color: Colors.blue),
                          onPressed: () {
                            // Implementar ligação
                          },
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Descrição
                  Text(
                    widget.info.descricao,
                    style: AppTextStyles.bodyText1,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  if (widget.info.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: widget.info.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Informações de contato
                  if (widget.info.telefone.isNotEmpty || widget.info.site.isNotEmpty)
                    CustomCard(
                      elevated: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informações de Contato',
                            style: AppTextStyles.headline3,
                          ),
                          const SizedBox(height: 8),
                          if (widget.info.telefone.isNotEmpty)
                            _buildContactInfo(Icons.phone, widget.info.telefone),
                          if (widget.info.site.isNotEmpty)
                            _buildContactInfo(Icons.language, widget.info.site),
                          if (widget.info.horariosFuncionamento.isNotEmpty)
                            ...widget.info.horariosFuncionamento.map((horario) {
                              return _buildContactInfo(Icons.access_time, horario);
                            }),
                          _buildContactInfo(Icons.location_on, widget.info.endereco),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Seção de Comentários
                  const Text(
                    'Comentários e Avaliações',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 12),
                  
                  // Campo para adicionar comentário
                  CustomCard(
                    elevated: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deixe seu comentário'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _comentarioController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Compartilhe sua experiência...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Avaliação (opcional)'),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _avaliacao.round() ? Icons.star : Icons.star_border,
                                  color: AppColors.accent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _avaliacao = (index + 1).toDouble();
                                  });
                                },
                              );
                            }),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                if (_comentarioController.text.trim().isNotEmpty) {
                                  final novoComentario = Comentario(
                                    usuarioId: widget.authService.currentUser?.id ?? '',
                                    usuarioNome: widget.authService.currentUser?.displayName ?? 'Anônimo',
                                    texto: _comentarioController.text.trim(),
                                    data: DateTime.now(),
                                    avaliacao: _avaliacao > 0 ? _avaliacao : null,
                                  );
                                  
                                  widget.onCommentAdded(novoComentario);
                                  _comentarioController.clear();
                                  setState(() {
                                    _avaliacao = 0.0;
                                  });
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Comentário adicionado!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Enviar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lista de comentários
                  if (widget.info.comentarios.isEmpty)
                    const Center(
                      child: Text('Nenhum comentário ainda. Seja o primeiro a comentar!'),
                    )
                  else
                    ...widget.info.comentarios.map((comentario) {
                      return CustomCard(
                        elevated: false,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  comentario.usuarioNome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (comentario.avaliacao != null)
                                  RatingWidget(
                                    rating: comentario.avaliacao!,
                                    showReviews: false,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comentario.texto,
                              style: AppTextStyles.bodyText2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${comentario.data.day}/${comentario.data.month}/${comentario.data.year}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 16),
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== BOTTOM SHEET DE FAVORITOS ==========
class FavoritesBottomSheet extends StatelessWidget {
  final List<LocalizacaoModel> favoritos;
  final Function(LocalizacaoModel) onLocationTap;

  const FavoritesBottomSheet({
    super.key,
    required this.favoritos,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusLarge),
          topRight: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meus Favoritos (${favoritos.length})',
                  style: AppTextStyles.headline2,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Lista de favoritos
          Expanded(
            child: favoritos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum local favoritado',
                          style: AppTextStyles.bodyText1.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toque no coração nos locais para adicionar aos favoritos',
                          style: AppTextStyles.bodyText2.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: favoritos.length,
                    itemBuilder: (context, index) {
                      final location = favoritos[index];
                      return CustomCard(
                        onTap: () => onLocationTap(location),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                                image: DecorationImage(
                                  image: AssetImage(location.imagem),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.nome,
                                    style: AppTextStyles.headline3,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    location.categoria,
                                    style: AppTextStyles.bodyText2,
                                  ),
                                  const SizedBox(height: 4),
                                  RatingWidget(
                                    rating: location.avaliacaoMedia,
                                    totalReviews: location.totalAvaliacoes,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ========== DIÁLOGO DE PERFIL COMPLETO ==========
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
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
                    icon: const Icon(Icons.edit),
                    onPressed: widget.onEditProfile,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Avatar e informações do perfil
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
                  child: widget.imagemPerfil == null && widget.usuarioAtual?.fotoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (widget.editandoPerfil)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
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
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.telefoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widget.bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.info),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                ),
              ),
            ] else ...[
              Text(
                widget.usuarioAtual?.nome ?? 'Usuário',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.usuarioAtual?.email ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (widget.usuarioAtual?.telefone != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.usuarioAtual!.telefone!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              if (widget.usuarioAtual?.bio != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Text(
                    widget.usuarioAtual!.bio!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Membro desde ${widget.usuarioAtual?.dataRegistro.day}/${widget.usuarioAtual?.dataRegistro.month}/${widget.usuarioAtual?.dataRegistro.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            const Divider(),
            
            // Seção de Feedback
            const Text(
              'Enviar Feedback',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sua opinião é importante para melhorarmos o app!',
              style: AppTextStyles.bodyText2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Digite seu feedback, sugestão ou problema...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botões de ação
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
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(widget.editandoPerfil ? 'Salvar Alterações' : 'Enviar Feedback'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}