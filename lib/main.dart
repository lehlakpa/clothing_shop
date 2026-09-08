import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

Timer? notificationTimer;

const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'time_channel',
      'Time Notifications',
      channelDescription: 'Notifications showing the current time',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

const NotificationDetails notificationDetails = NotificationDetails(
  android: androidNotificationDetails,
);

/// Tracks whether the app is currently visible to the user.
/// Used to decide: in-app banner (foreground) vs system push (background).
final ValueNotifier<bool> isAppInForeground = ValueNotifier<bool>(true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await notificationPlugin.initialize(settings: initializationSettings);

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  await androidPlugin?.requestNotificationsPermission();

  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'time_channel',
      'Time Notifications',
      description: 'Notifications showing the current time',
      importance: Importance.high,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Notification Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const NotificationScreen(),
    );
  }
}

// ==================================================
// NOTIFICATION SCREEN
// ==================================================

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  bool isRunning = false;

  // In-app banner state
  String? bannerMessage;
  Timer? bannerHideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // ==================================================
  // APP LIFECYCLE — foreground vs background detection
  // ==================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        isAppInForeground.value = true;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        isAppInForeground.value = false;
        break;
    }
  }

  // ==================================================
  // START / STOP
  // ==================================================

  void startNotifications() {
    if (isRunning) return;

    setState(() => isRunning = true);

    deliverTimeNotification();

    notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      deliverTimeNotification();
    });
  }

  void stopNotifications() {
    notificationTimer?.cancel();
    notificationTimer = null;
    setState(() => isRunning = false);
  }

  // ==================================================
  // DELIVER — routes to in-app banner OR system push
  // ==================================================

  Future<void> deliverTimeNotification() async {
    final DateTime now = DateTime.now();
    final String currentTime =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    if (isAppInForeground.value) {
      // App is open and visible — show an in-app banner instead of
      // a system notification, so we don't duplicate/annoy the user.
      showInAppBanner('It is $currentTime');
    } else {
      // App is backgrounded/closed — deliver a real system notification.
      await notificationPlugin.show(
        id: 100,
        title: 'Current Time',
        body: 'It is $currentTime',
        notificationDetails: notificationDetails,
      );
    }
  }

  void showInAppBanner(String message) {
    bannerHideTimer?.cancel();

    setState(() => bannerMessage = message);

    bannerHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => bannerMessage = null);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    notificationTimer?.cancel();
    bannerHideTimer?.cancel();
    super.dispose();
  }

  // ==================================================
  // UI
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'Notification Center',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAppInForeground.value
                      ? 'Foreground mode: alerts show as in-app banners'
                      : 'Background mode: alerts show as push notifications',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),

                const Spacer(),

                // Main status card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: isRunning
                                ? const Color(0xFF6C63FF).withOpacity(0.12)
                                : Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRunning
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_rounded,
                            size: 64,
                            color: isRunning
                                ? const Color(0xFF6C63FF)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isRunning ? 'Running' : 'Stopped',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Delivers a time update every 30 seconds',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isRunning ? null : startNotifications,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: isRunning ? stopNotifications : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6C63FF),
                              side: const BorderSide(color: Color(0xFF6C63FF)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // In-app banner (only shown while app is in foreground)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: bannerMessage != null ? 16 : -120,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Time',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(bannerMessage ?? ''),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => setState(() => bannerMessage = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:clothing_shop/practise_screens/practise_provider.dart';
// import 'package:clothing_shop/providers/auth_provider.dart';
// import 'package:clothing_shop/providers/banner_provider.dart';
// import 'package:clothing_shop/providers/location_provider.dart';
// import 'package:clothing_shop/screens/google_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'firebase_options.dart';

// import 'providers/product_provider.dart';
// import 'providers/cart_provider.dart';
// import 'providers/wishlist_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ProductProvider()),
//         ChangeNotifierProvider(create: (_) => BannerProvider()),
//         ChangeNotifierProvider(create: (_) => CartProvider()),
//         ChangeNotifierProvider(create: (_) => WishlistProvider()),
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => PractiseProvider()),
//         ChangeNotifierProvider(create: (_) => AuthProvider()..getProfile()),
//         ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
//         ChangeNotifierProvider(create: (_) => LocationProvider()),
//       ],
//       child: const KiooApp(),
//     ),
//   );
// }

// class KiooApp extends StatelessWidget {
//   const KiooApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'lakpa JI',

//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xFFF6F1E6),
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF223B2E)),
//         fontFamily: 'Manrope',
//         useMaterial3: true,
//       ),

//       home: GoogleScreen(),
//     );
//   }
// }
