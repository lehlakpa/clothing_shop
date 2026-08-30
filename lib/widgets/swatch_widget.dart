import 'package:flutter/material.dart';

class SwatchWidget extends StatelessWidget {
  const SwatchWidget({super.key, required this.colors, required this.radius});

  final List<String> colors;
  final double radius;

  Color _parseColor(String value) {
    final hex = value.replaceFirst('#', '');
    if (hex.length != 6) return const Color(0xFFE3D8C3);
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final swatchColors = colors.isEmpty
        ? const [Color(0xFFE3D8C3), Color(0xFFBCA785)]
        : colors.map(_parseColor).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: swatchColors,
        ),
      ),
    );
  }
}
