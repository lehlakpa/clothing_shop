import 'package:clothing_shop/practise.dart';
import 'package:clothing_shop/practise_screens/practise_provider.dart';
import 'package:clothing_shop/screens/login_screen.dart';
import 'package:clothing_shop/widgets/custom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _checkFuture;

  @override
  void initState() {
    super.initState();
    _checkFuture = context.read<PractiseProvider>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final loggedIn = snapshot.data ?? false;
        return loggedIn ? const Practise() : LoginPage();
      },
    );
  }
}
