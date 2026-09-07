import 'package:clothing_shop/practise.dart';
import 'package:clothing_shop/practise_screens/practise_provider.dart';
import 'package:clothing_shop/widgets/custom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _Palette {
  static const ink = Color(0xFF1C1C1E);
  static const paper = Color(0xFFFAF9F7);
  static const accent = Color(0xFFB5533C);
  static const sub = Color(0xFF8A8A94);
  static const line = Color(0xFFE3E1DC);
  static const error = Color(0xFFC0392B);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<PractiseProvider>();
    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Practise()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect username or password. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _Palette.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _Palette.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter your details to continue.',
                    style: TextStyle(fontSize: 13, color: _Palette.sub),
                  ),
                  const SizedBox(height: 32),

                  _field(
                    controller: _usernameController,
                    label: 'Username',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.trim().length < 3) {
                        return 'Must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _field(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _isPasswordObscured,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: _Palette.sub,
                      ),
                      onPressed: () {
                        setState(
                          () => _isPasswordObscured = !_isPasswordObscured,
                        );
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 15,
                          color: _Palette.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _Palette.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _Palette.ink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),

                  Center(
                    child: TextButton(
                      // UI placeholder only — not wired to a reset flow yet.
                      onPressed: _isLoading ? null : () {},
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(fontSize: 12.5, color: _Palette.sub),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14, color: _Palette.ink),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: _Palette.sub),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _Palette.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _Palette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _Palette.accent, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _Palette.error),
        ),
      ),
    );
  }
}
