import 'package:clothing_shop/screens/location_screen.dart';
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
        Row(
          children: [
            // Location Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LocationScreen()),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.forest,
                  size: 20,
                ),
              ),
            ),
            // Avatar
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
        ),
      ],
    );
  }
}
