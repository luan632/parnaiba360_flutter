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
  final _formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();
  bool _isLoading = false;
  bool _obscurePassword = true; // Controla se a senha está oculta

  void _handleImagePick(File image) {
    _formData.image = image;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_formData.issingnup && _formData.image == null) {
      return _showError('Por favor, selecione uma imagem de perfil!');
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        _formData.islogin
            ? 'http://127.0.0.1:8000/api/login'
            : 'http://127.0.0.1:8000/api/register',
      );

      if (_formData.issingnup && _formData.image != null) {
        final request = http.MultipartRequest('POST', url)
          ..fields['email'] = _formData.email
          ..fields['password'] = _formData.password
          ..fields['name'] = _formData.name
          ..files.add(await http.MultipartFile.fromPath('image', _formData.image!.path));

        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          widget.onSubmit(_formData);
        } else {
          final message = jsonDecode(responseData)['message'] ?? 'Erro no registro';
          _showError(message);
        }
      } else {
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
      _showError('Ocorreu um erro inesperado');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cor azul principal
    final primaryColor = Color(0xFF3F51B5); // Azul profundo (Material Indigo 600)

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Text(
                _formData.islogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Título azul
                ),
              ),
              const SizedBox(height: 16),

              // Subtítulo
              Text(
                _formData.islogin
                    ? 'Faça login para continuar'
                    : 'Preencha os dados para se registrar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 28),

              // Seletor de imagem (apenas no cadastro)
              if (_formData.issingnup)
                Column(
                  children: [
                    UserImagePicker(onImagePick: _handleImagePick),
                    const SizedBox(height: 20),
                  ],
                ),

              // Campo Nome Completo
              if (_formData.issingnup)
                _buildInputField(
                  context,
                  label: 'Nome Completo',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Nome deve ter no mínimo 5 caracteres.';
                    }
                    return null;
                  },
                  onChanged: (value) => _formData.name = value ?? '',
                  key: const ValueKey('name'),
                ),

              const SizedBox(height: 16),

              // Campo Email
              _buildInputField(
                context,
                label: 'E-mail',
                icon: Icons.email,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
                onChanged: (value) => _formData.email = value ?? '',
                key: const ValueKey('email'),
              ),

              const SizedBox(height: 16),

              // Campo Senha (com labelStyle e foco azul)
              TextFormField(
                key: const ValueKey('password'),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return TextStyle(color: primaryColor, fontSize: 16);
                    }
                    return TextStyle(color: Colors.grey[600], fontSize: 16);
                  }),
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Senha deve ter no mínimo 6 caracteres.';
                  }
                  return null;
                },
                onChanged: (value) => _formData.password = value ?? '',
                style: const TextStyle(fontSize: 16),
                cursorColor: primaryColor,
              ),

              const SizedBox(height: 24),

              // Botão de Ação
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Fundo azul
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _formData.islogin ? 'Entrar' : 'Cadastrar',
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Botão de alternância (texto azul)
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _formData.toggleAuthMode();
                        });
                      },
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor, // Texto azul
                  textStyle: const TextStyle(fontSize: 15),
                ),
                child: Text(
                  _formData.islogin
                      ? 'Não tem uma conta? Cadastre-se'
                      : 'Já tem uma conta? Faça login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Campo de entrada personalizado com label azul ao focar
  Widget _buildInputField(
    BuildContext context, {
    required String label,
    IconData? icon,
    required FormFieldValidator<String?> validator,
    required ValueChanged<String?> onChanged,
    required Key key,
  }) {
    final primaryColor = Color(0xFF3F51B5);

    return TextFormField(
      key: key,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return TextStyle(color: primaryColor, fontSize: 16);
          }
          return TextStyle(color: Colors.grey[600], fontSize: 16);
        }),
        prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      cursorColor: primaryColor,
    );
  }
}