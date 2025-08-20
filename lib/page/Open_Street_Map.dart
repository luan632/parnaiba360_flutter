import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'package:parnaiba360_flutter/core/service/auth/auth_service.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_mock_service.dart';
import 'package:parnaiba360_flutter/core/models/pontos_turisticos.dart';
import 'package:parnaiba360_flutter/core/service/api_services.dart';

// Modelo de Usuário para armazenar dados do perfil
class Usuario {
  String id;
  String nome;
  String email;
  String? fotoUrl;
  String? telefone;
  String? bio;
  DateTime dataRegistro;

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

  @override
  void initState() {
    super.initState();
    futurePontos = ApiServices().getPontos();
    _carregarDadosUsuario();
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
        _usuarioAtual = Usuario(
          id: _usuarioAtual!.id,
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text.isNotEmpty ? _telefoneController.text : null,
          bio: _bioController.text.isNotEmpty ? _bioController.text : null,
          dataRegistro: _usuarioAtual!.dataRegistro,
          fotoUrl: _usuarioAtual!.fotoUrl, // Manter a URL existente (em app real faria upload da nova imagem)
        );
        
        _editandoPerfil = false;
      });
      
      // Aqui você implementaria a lógica para salvar no backend
      print('Perfil salvo: ${_usuarioAtual!.toJson()}');
    }
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
      'categoria': 'Ponto Turístico',
      'preco': 0,
    },
    // ... outros pontos turísticos
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
      'categoria': 'Hotel',
      'preco': 3,
    },
    // ... outros hotéis
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
      'categoria': 'Restaurante',
      'preco': 3,
    },
    // ... outros restaurantes
  ];

  // Combina todas as localizações
  List<Map<String, dynamic>> get allLocations {
    return [
      ...pontosTuristicos,
      ...hoteis,
      ...restaurantes,
    ];
  }

  // Gera marcadores dinamicamente
  List<Map<String, dynamic>> _generateMarkers(
      List<Map<String, dynamic>> locations, String type, Color color) {
    return locations.map((location) {
      return {
        'type': type,
        'nome': location['nome'],
        'data': location,
        'marker': Marker(
          point: LatLng(location['lat'], location['lng']),
          width: 40,
          height: 40,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (_) => GestureDetector(
            onTap: () {
              _showMarkerInfo(context, location);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                type == 'Ponto Turístico'
                    ? Icons.landscape
                    : type == 'Hotel'
                        ? Icons.hotel
                        : Icons.restaurant,
                color: color,
                size: 24,
              ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      if (info['imagem'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            info['imagem'],
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    info['nome'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (info['preco'] != null && info['preco'] > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '\$' * info['preco'],
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    info['descricao'] ?? info['descricao'],
                    style: const TextStyle(fontSize: 16, height: 1.4),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          info['endereco'],
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                    controller: _comentarioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deixe seu comentário',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
        },
      ),
    );
  }

  // Retorna marcadores filtrados
  List<Marker> getFilteredMarkers() {
    List<Map<String, dynamic>> allMarkers = [];
    allMarkers.addAll(_generateMarkers(pontosTuristicos, 'Ponto Turístico', Colors.red));
    allMarkers.addAll(_generateMarkers(hoteis, 'Hotel', Colors.blue));
    allMarkers.addAll(_generateMarkers(restaurantes, 'Restaurante', Colors.green));

    // Aplicar filtros
    List<Map<String, dynamic>> filteredMarkers = allMarkers.where((marker) {
      // Filtro por categoria
      if (selectedFilter != 'Todos' && marker['type'] != selectedFilter) {
        return false;
      }
      
      // Filtro por texto de busca
      if (_searchController.text.isNotEmpty) {
        final nome = marker['nome'].toString().toLowerCase();
        if (!nome.contains(_searchController.text.toLowerCase())) {
          return false;
        }
      }
      
      return true;
    }).toList();

    return filteredMarkers.map((m) => m['marker'] as Marker).toList();
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
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_editandoPerfil ? 'Editar Perfil' : 'Meu Perfil'),
                if (!_editandoPerfil)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      setStateDialog(() {
                        _editandoPerfil = true;
                      });
                    },
                  ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue,
                        backgroundImage: _imagemPerfil != null
                            ? FileImage(_imagemPerfil!) as ImageProvider
                            : (_usuarioAtual?.fotoUrl != null
                                ? NetworkImage(_usuarioAtual!.fotoUrl!)
                                : const AssetImage('assets/images/default_avatar.png')) as ImageProvider,
                        child: _editandoPerfil
                            ? Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, size: 20),
                                    onPressed: () {
                                      _showImageSourceDialog(context);
                                    },
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_editandoPerfil) ...[
                    TextField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telefoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bioController,
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
                      _usuarioAtual?.nome ?? 'Usuário',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _usuarioAtual?.email ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (_usuarioAtual?.telefone != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _usuarioAtual!.telefone!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    if (_usuarioAtual?.bio != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _usuarioAtual!.bio!,
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Membro desde ${_usuarioAtual?.dataRegistro.day}/${_usuarioAtual?.dataRegistro.month}/${_usuarioAtual?.dataRegistro.year}',
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
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Digite seu feedback aqui...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (_editandoPerfil)
                TextButton(
                  onPressed: () {
                    setStateDialog(() {
                      _editandoPerfil = false;
                      // Restaurar valores originais
                      _nomeController.text = _usuarioAtual?.nome ?? '';
                      _emailController.text = _usuarioAtual?.email ?? '';
                      _telefoneController.text = _usuarioAtual?.telefone ?? '';
                      _bioController.text = _usuarioAtual?.bio ?? '';
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ElevatedButton(
                onPressed: () {
                  if (_editandoPerfil) {
                    _salvarPerfil();
                    setStateDialog(() {
                      _editandoPerfil = false;
                    });
                  }
                  
                  if (_feedbackController.text.isNotEmpty) {
                    _sendFeedback();
                    _feedbackController.clear();
                  }
                  
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_editandoPerfil 
                          ? 'Perfil atualizado com sucesso!' 
                          : 'Feedback enviado com sucesso!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(_editandoPerfil ? 'Salvar' : 'Enviar'),
              ),
            ],
          );
        },
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
    print('Feedback enviado: ${_feedbackController.text}');
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                  child: const Text('Limpar Filtros'),
                ),
              ],
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
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.yellowAccent, size: 28),
            const SizedBox(width: 10),
            Text(
              'Parnaíba360',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: const [
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFiltersPanel = !_showFiltersPanel;
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2980),  // Azul escuro
              Color(0xFF26D0CE),  // Ciano
            ],
          ),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: parnaibaLocation,
                zoom: 13,
                minZoom: 0,
                maxZoom: 100,
                onPositionChanged: (MapPosition position, bool hasGesture) {
                  if (hasGesture) {
                    // O usuário moveu o mapa manualmente
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", 
                ),
                CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      color: Colors.blue,
                      child: const Icon(Icons.person_pin_circle, color: Colors.white),
                    ),
                    markerSize: const Size(40, 40),
                    accuracyCircleColor: Colors.blue.withOpacity(0.3),
                    headingSectorColor: Colors.blue,
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
                    backgroundColor: Colors.blue,
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
                      });
                    },
                    backgroundColor: _showFiltersPanel ? Colors.orange : Colors.blue,
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