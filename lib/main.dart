import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/page/auth_or_app_page.dart';
import 'package:parnaiba360_flutter/page/auth_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.blue),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/praia.jpg'), // Altere para o caminho da sua imagem
              fit: BoxFit.cover,
            ),
          ),
          child: const AuthOrAppPage(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}