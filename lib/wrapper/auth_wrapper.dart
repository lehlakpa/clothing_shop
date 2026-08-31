import 'package:clothing_shop/providers/auth_provider.dart';
import 'package:clothing_shop/widgets/custom_navigation.dart';
import 'package:clothing_shop/widgets/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.token != null && auth.token!.isNotEmpty) {
      return const CustomNavigation();
    }

    return const LoginPage();
  }
}
