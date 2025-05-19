import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/page/auth_or_app_page.dart';
import 'package:parnaiba360_flutter/page/auth_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.blue),
      home: AuthOrAppPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}