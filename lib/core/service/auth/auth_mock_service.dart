import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:parnaiba360_flutter/core/models/chat_user.dart';
import 'package:parnaiba360_flutter/core/service/auth/auth_service.dart';

class AuthMockService implements AuthService {
  static final AuthMockService _instance = AuthMockService._();
  static Map<String, ChatUser> _users = {};
  static ChatUser? _currentUser;
  static MultiStreamController<ChatUser?>? _controller;
  static final _userStream = Stream<ChatUser?>.multi((controller) {
    _controller = controller;
    _updateUser(null);
  });

  // Padrão singleton
  factory AuthMockService() {
    return _instance;
  }

  AuthMockService._();

  ChatUser? get currentUser => _currentUser;

  Stream<ChatUser?> get userChanges => _userStream;

  Future<void> signup(
    String name,
    String email,
    String password,
    File? image,
  ) async {
    final newUser = ChatUser(
      id: Random().nextDouble().toString(), 
      name: name,
      email: email, 
      imageURL: image?.path ?? '/assets/images/...',
    );

    _users.putIfAbsent(email, () => newUser);
    _updateUser(newUser);
  }

  Future<void> login(String email, String password) async {
    _updateUser(_users[email]);
  }

  Future<void> logout() async {
    _updateUser(null);
  }

  static void _updateUser(ChatUser? user) {
    _currentUser = user;
    _controller?.add(_currentUser);
  }
}