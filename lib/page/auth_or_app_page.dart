import 'package:flutter/material.dart';
import 'package:parnaiba360_flutter/core/models/chat_user.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_mock_service.dart';
import 'package:parnaiba360_flutter/page/auth_page.dart';
import 'package:parnaiba360_flutter/page/loading_pages.dart';
import 'package:parnaiba360_flutter/page/maps_page.dart';

class AuthOrAppPage extends StatelessWidget {
  const AuthOrAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ChatUser?>(
        stream: AuthMockService().userChanges,
        builder: (ctx, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return LoadingPages();
          }else {
            return snapshot.hasData ? MapsPage() : AuthPage();
          }
        }
      ),
    );
  }
}