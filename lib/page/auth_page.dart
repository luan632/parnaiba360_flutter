import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/components/auth_form.dart';
import 'package:parnaiba360_flutter/models/auth_form_data.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;
  void handleSubmit(AuthFormData formData) {
    setState(() => _isLoading = true);
    print('AuthPage...');
    print(formData.email);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: AuthForm(onSubmit: handleSubmit),
            ),
          ),
          if (_isLoading)Container(
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