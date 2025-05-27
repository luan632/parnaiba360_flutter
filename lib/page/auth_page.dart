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

      if (formData.islogin) {
        // login
        await AuthMockService().login(formData.email, formData.password);
      } else {
        // signup
        await AuthMockService().signup(
          formData.name,
          formData.email,
          formData.password,
          formData.image,
        );
      }
    } catch (error) {
      // Tratar erro aqui
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/praia.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Conteúdo centralizado sobre a imagem
          Center(
            child: SingleChildScrollView(
              child: AuthForm(onSubmit: _handleSubmit),
            ),
          ),

          // Overlay de carregamento
          if (_isLoading)
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.5),
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}