import 'dart:io';

enum AuthMode {signup, login}

class AuthFormData {
  String name = '';
  String email = '';
  String password  = '';
  File? imagem ;
  AuthMode mode_ = AuthMode.login;

  bool get islogin{
    return mode_ == AuthMode.login;
  }

  bool get issingnup {
    return mode_ == AuthMode.signup;
  }

  void toggleAuthMode(){
    mode_ = islogin ? AuthMode.signup : AuthMode.login; 

  }


}