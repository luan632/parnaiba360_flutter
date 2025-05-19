import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_mock_service.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Maps page'),
            TextButton(
              onPressed: () {
                // Adicione aqui a ação do botão
                AuthMockService().logout();
              }, 
              child: const Text('Logout')
            )
          ],
        ),
      ),
    );
  }
}