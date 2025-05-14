import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/models/auth_form_data.dart';

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
  final formData = AuthFormData();

  void _submit() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    widget.onSubmit(formData);
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
              if (formData.issingnup) // Corrigido para isSignup (verifique o nome exato na sua classe)
                TextFormField(
                  key: ValueKey('name'),
                  initialValue: formData.name,
                  onChanged: (name) => formData.name = name,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (_name) {
                    final name = _name ?? '';
                    if (name.trim().length < 5) {
                      return 'Nome deve ter no mínimo 5 caracteres.'; // Corrigido para ser consistente
                    }
                    return null;
                  },
                ),
              TextFormField(
                key: ValueKey('email'),
                initialValue: formData.email,
                onChanged: (email) => formData.email = email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (_email) {
                  final email = _email ?? '';
                  if (!email.contains('@')) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: ValueKey('password'),
                initialValue: formData.password,
                onChanged: (password) => formData.password = password,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Senha'),
                validator: (_password) {
                  final password = _password ?? '';
                  if (password.length < 6) {
                    return 'Senha deve ter no mínimo 6 caracteres.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(formData.islogin ? 'Entrar' : 'Cadastrar'), // Corrigido texto do botão
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    formData.toggleAuthMode();
                  });
                },
                child: Text(
                  formData.islogin
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