import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_course/core/router.dart';
import 'package:go_router_course/repositories/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.redirectTo});

  final String? redirectTo;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              authRepository.loggedUser = User(true);
              context.go(widget.redirectTo ?? '/');
            },
            child: Text('Logar')),
      ),
    );
  }
}
