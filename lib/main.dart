import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/page/auth_or_app_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parnaíba 360',
      theme: ThemeData(primaryColor: Colors.blue),
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/praia.jpg'),
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