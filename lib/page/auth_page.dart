import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/components/auth_form.dart';
import 'package:parnaiba360_flutter/models/auth_form_data.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  void handleSubmit (AuthFormData formData){
    print('AuthPage...');
    print(formData.email);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: AuthForm(onSubmit: handleSubmit,),
        ),
      ),
    );
  }
}