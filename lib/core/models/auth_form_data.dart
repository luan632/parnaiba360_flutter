import 'dart:io';

enum AuthMode {signup, login}

class AuthFormData {
  String name = '';
  String email = '';
  String password  = '';
  File? image ;
  AuthMode mode_ = AuthMode.login;

  bool get islogin{
    return mode_ == AuthMode.login;
  }

  bool get issingnup {
    return mode_ == AuthMode.signup;
  }

  get currentState => null;

  void toggleAuthMode(){
    mode_ = islogin ? AuthMode.signup : AuthMode.login; 

  }


}