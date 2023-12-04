import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}): super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();

}
class _LoginPageState extends State<LoginPage> {

  String? errorMessage = '';
  bool isLogin = true;
  final TextEditingController _controllerEmail= TextEditingController();
  final TextEditingController _controllerPassword= TextEditingController();
  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    }on FirebaseAuthException catch (e) {
      setState((){
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }
  Widget _entryField(
      String title,
      TextEditingController controller,{bool isPassword = false}
      ) {
      return TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(labelText: title,),
      ); // InputDecoration ); // TextField
  }

  Widget _errorMessage() {
    return Text (errorMessage =='' ?'' : 'Humm? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
        isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    ); // ElevatedButton
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin =!isLogin;
        });
      },
      child: Text(isLogin ? 'Register instead': 'Login instead'),
    ); // TextButton
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ), // AppBar
      body: Container(
        height: double.infinity,
        width: double.infinity, padding: const EdgeInsets.all(20),
        child: Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _entryField('email', _controllerEmail),
              _entryField('password', _controllerPassword,isPassword: true),
              _errorMessage(),
              _submitButton(),
              _loginOrRegisterButton(),
            ],
      ),
    ),
    );
}
}