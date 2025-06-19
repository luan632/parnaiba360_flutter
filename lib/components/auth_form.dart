import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parnaiba360_flutter/components/user_image_picker.dart';
import 'package:parnaiba360_flutter/core/models/auth_form_data.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  final void Function(AuthFormData) onSubmit;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();
  bool _isLoading = false;

  void _handleImagePick(File image) {
    _formData.image = image;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_formData.image == null && _formData.issingnup) {
      return _showError('Imagem Não Selecionada!');
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        _formData.islogin
            ? 'http://127.0.0.1:8000/api/login'
            : 'http://127.0.0.1:8000/api/register',
      );

      // Se for cadastro e tiver imagem, usa MultipartRequest
      if (_formData.issingnup && _formData.image != null) {
        var request = http.MultipartRequest('POST', url);
        
        request.fields['email'] = _formData.email;
        request.fields['password'] = _formData.password;
        request.fields['name'] = _formData.name;
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', 
            _formData.image!.path,
          ),
        );
        
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          widget.onSubmit(_formData);
        } else {
          _showError(jsonDecode(responseData)['message'] ?? 'Erro no registro');
        }
      } else {
        // Requisição normal para login ou registro sem imagem
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _formData.email,
            'password': _formData.password,
            if (_formData.issingnup) 'name': _formData.name,
          }),
        );

        final responseData = jsonDecode(response.body);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          widget.onSubmit(_formData);
        } else {
          _showError(responseData['message'] ?? 'Erro na autenticação');
        }
      }
    } on SocketException {
      _showError('Sem conexão com a internet');
    } on http.ClientException {
      _showError('Erro ao conectar com o servidor');
    } on FormatException {
      _showError('Erro no formato dos dados');
    } catch (error) {
      _showError('Ocorreu um erro inesperado: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              if (_formData.issingnup)
                UserImagePicker(
                  onImagePick: _handleImagePick,
                ),
              if (_formData.issingnup)
                TextFormField(
                  key: const ValueKey('name'),
                  initialValue: _formData.name,
                  onChanged: (name) => _formData.name = name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (_name) {
                    final name = _name ?? '';
                    if (name.trim().length < 5) {
                      return 'Nome deve ter no mínimo 5 caracteres.';
                    }
                    return null;
                  },
                ),
              TextFormField(
                key: const ValueKey('email'),
                initialValue: _formData.email,
                onChanged: (email) => _formData.email = email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (_email) {
                  final email = _email ?? '';
                  if (!email.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const ValueKey('password'),
                initialValue: _formData.password,
                onChanged: (password) => _formData.password = password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (_password) {
                  final password = _password ?? '';
                  if (password.length < 6) {
                    return 'Senha deve ter no mínimo 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_formData.islogin ? 'Entrar' : 'Cadastrar'),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _formData.toggleAuthMode();
                        });
                      },
                child: Text(
                  _formData.islogin
                      ? 'Criar uma nova conta?'
                      : 'Já possui conta?',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}