import 'package:flutter/material.dart';
import 'app_colors.dart';

class HeaderSection extends StatelessWidget {
  final String userName;

  const HeaderSection({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GOOD MORNING',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.sub,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 27,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.forest,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : '',
            style: const TextStyle(
              color: AppColors.paper,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
