import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/components/auth_form.dart';
import 'package:parnaiba360_flutter/core/models/auth_form_data.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_mock_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;

  Future<void> _handleSubmit(AuthFormData formData) async {
    try {
      setState(() => _isLoading = true);

      if (formData.islogin) { // Corrigido: islogin → isLogin
        // login
        await AuthMockService().login(formData.email, formData.password);
      } else {
        // signup
        await AuthMockService().signup(
          formData.name,
          formData.email,
          formData.password,
        );
      }
      
      // Navegar para a próxima tela após sucesso
      // Navigator.of(context).pushReplacementNamed('/home');
      
    } catch (error) {
      // Tratar erro de forma mais robusta
      _showErrorDialog(error.toString());
    } finally {
      if (mounted) { // Verifica se o widget ainda está montado
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Conteúdo centralizado sobre o gradiente
            Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  child: AuthForm(onSubmit: _handleSubmit),
                ),
              ),
            ),

            // Overlay de carregamento
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}