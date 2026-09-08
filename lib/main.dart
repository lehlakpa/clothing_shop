import 'package:clothing_shop/practise_screens/practise_provider.dart';
import 'package:clothing_shop/providers/auth_provider.dart';
import 'package:clothing_shop/providers/banner_provider.dart';
import 'package:clothing_shop/providers/location_provider.dart';
// import 'package:clothing_shop/widgets/custom_navigation.dart';
import 'package:clothing_shop/wrapper/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PractiseProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..getProfile()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const KiooApp(),
    ),
  );
}

class KiooApp extends StatelessWidget {
  const KiooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'lakpa JI',

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F1E6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF223B2E)),
        fontFamily: 'Manrope',
        useMaterial3: true,
      ),

      home: const AuthWrapper(),
    );
  }
}
