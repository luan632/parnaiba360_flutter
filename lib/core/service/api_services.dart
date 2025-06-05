import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parnaiba360_flutter/core/models/pontos_turisticos.dart';

class ApiServices {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      })
    );

    if (response.statusCode != 201){
      throw Exception('Erro ao registrar');
    }
  }

  Future<List<PontosTuristicos>> getPontos() async {
  final response = await http.get(Uri.parse('$baseUrl/pontos-turisticos'));

  if (response.statusCode != 200) {
    throw Exception('Erro ao carregar os pontos turisticos');
  }

  final List<dynamic> jsonList = jsonDecode(response.body);
  return jsonList
    .map((item) => PontosTuristicos.fromJson(item))
    .toList();
  }
}
