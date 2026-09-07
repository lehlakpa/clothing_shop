import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final int? statusCode;

  const ErrorDisplayWidget({super.key, required this.message, this.statusCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (statusCode != null)
              Text(
                'Error Code: $statusCode',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}
