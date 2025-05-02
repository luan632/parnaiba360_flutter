import 'package:flutter/material.dart';

class LoadingPages extends StatelessWidget {
  const LoadingPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
            'Carregando...', 
            style: TextStyle(
              color: Colors.white
            ),)

          ],
        ),
      ),
    );
  }
}