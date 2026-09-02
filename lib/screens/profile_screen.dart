import 'package:clothing_shop/widgets/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,

      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        ),
      ),

      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final profile = auth.profile;

          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final username = profile['username'] ?? 'Unknown';
          final email = profile['email'] ?? '';
          final firstName = profile['firstName'] ?? '';
          final lastName = profile['lastName'] ?? '';
          final image = profile['image'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // PROFILE IMAGE
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.cream,
                  backgroundImage: image != null ? NetworkImage(image) : null,
                  child: image == null
                      ? const Icon(Icons.person, size: 55, color: AppColors.sub)
                      : null,
                ),

                const SizedBox(height: 18),

                // USERNAME
                Text(
                  username,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // NAME
                if (firstName.isNotEmpty || lastName.isNotEmpty)
                  Text(
                    '$firstName $lastName'.trim(),
                    style: const TextStyle(color: AppColors.sub, fontSize: 15),
                  ),

                const SizedBox(height: 5),

                // EMAIL
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: const TextStyle(color: AppColors.sub, fontSize: 13),
                  ),

                const SizedBox(height: 40),

                // PROFILE INFORMATION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      _profileRow(Icons.person_outline, 'Username', username),

                      const Divider(height: 25, color: AppColors.line),

                      _profileRow(Icons.email_outlined, 'Email', email),

                      if (firstName.isNotEmpty || lastName.isNotEmpty) ...[
                        const Divider(height: 25, color: AppColors.line),
                        _profileRow(
                          Icons.badge_outlined,
                          'Name',
                          '$firstName $lastName'.trim(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PROFILE ROW
  // ============================================================

  Widget _profileRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: AppColors.forest),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.sub, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.paper,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.sub),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
