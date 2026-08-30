import 'package:clothing_shop/providers/banner_provider.dart';
import 'package:clothing_shop/widgets/custom_navigation.dart';
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
      title: 'Kioo',

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F1E6),

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF223B2E)),

        fontFamily: 'Manrope',

        useMaterial3: true,
      ),

      home: CustomNavigation(),
    );
  }
}

// import 'package:clothing_shop/firebase_options.dart';
// import 'package:clothing_shop/providers/product_provider.dart';
// import 'package:clothing_shop/screens/practise_stream.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(
//     MultiProvider(
//       providers: [ChangeNotifierProvider(create: (_) => ProductProvider())],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Product Manager',
//       home: const PractiseStream(),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const BeautyStoreApp());
// }

// // ================================================================
// // APP
// // ================================================================
// class BeautyStoreApp extends StatelessWidget {
//   const BeautyStoreApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Beauty Store',
//       theme: ThemeData(
//         scaffoldBackgroundColor: Colors.white,
//         fontFamily: 'Arial',
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1C1C1C)),
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

// // ================================================================
// // CART MODEL + SIMPLE STATE
// // ================================================================
// class CartItem {
//   final Product product;
//   int quantity;

//   CartItem({required this.product, this.quantity = 1});
// }

// class CartState extends ChangeNotifier {
//   final List<CartItem> _items = [];

//   List<CartItem> get items => List.unmodifiable(_items);

//   int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

//   double get totalPrice => _items.fold(
//     0.0,
//     (sum, item) => sum + (item.product.price * item.quantity),
//   );

//   void add(Product product, {int qty = 1}) {
//     final existing = _items.indexWhere((e) => e.product.name == product.name);
//     if (existing >= 0) {
//       _items[existing].quantity += qty;
//     } else {
//       _items.add(CartItem(product: product, quantity: qty));
//     }
//     notifyListeners();
//   }

//   void remove(Product product) {
//     _items.removeWhere((e) => e.product.name == product.name);
//     notifyListeners();
//   }

//   void updateQuantity(Product product, int qty) {
//     final index = _items.indexWhere((e) => e.product.name == product.name);
//     if (index >= 0) {
//       if (qty <= 0) {
//         _items.removeAt(index);
//       } else {
//         _items[index].quantity = qty;
//       }
//       notifyListeners();
//     }
//   }

//   void clear() {
//     _items.clear();
//     notifyListeners();
//   }
// }

// final cartState = CartState();

// // ================================================================
// // HOME SCREEN (with bottom nav)
// // ================================================================
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int selectedIndex = 0;

//   final List<Product> products = [
//     Product(
//       brand: 'The Ordinary',
//       name: 'Hyaluronic Acid 2% + B5',
//       price: 14.50,
//       image:
//           'https://images.unsplash.com/photo-1611930022073-b7a4ba5fcccd?auto=format&fit=crop&w=500&q=80',
//       description:
//           'A lightweight serum with pure hyaluronic acid and vitamin B5 that hydrates and plumps the skin for a smoother appearance.',
//     ),
//     Product(
//       brand: 'The Ordinary',
//       name: 'Glycolic Acid 7% Toning',
//       price: 14.50,
//       image:
//           'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?auto=format&fit=crop&w=500&q=80',
//       description:
//           'An exfoliating toner that targets texture, uneven tone and signs of aging with 7% glycolic acid.',
//     ),
//     Product(
//       brand: 'The Ordinary',
//       name: 'Caffeine Solution 5%',
//       price: 14.50,
//       image:
//           'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?auto=format&fit=crop&w=500&q=80',
//       description:
//           'A targeted eye serum that reduces the appearance of puffiness and dark circles with caffeine and EGCG.',
//     ),
//     Product(
//       brand: 'CeraVe',
//       name: 'Foaming Facial Cleanser',
//       price: 12.00,
//       image:
//           'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=500&q=80',
//       description:
//           'Gentle foaming cleanser that removes dirt, oil and makeup while maintaining the skin barrier with ceramides.',
//     ),
//     Product(
//       brand: 'Murad',
//       name: 'Retinol Youth Renewal Cream',
//       price: 22.00,
//       image:
//           'https://images.unsplash.com/photo-1611930022073-b7a4ba5fcccd?auto=format&fit=crop&w=500&q=80',
//       description:
//           'Advanced retinol cream that visibly lifts, firms and smooths overnight with Tri-Active Technology.',
//     ),
//     Product(
//       brand: 'Neutrogena',
//       name: 'Hydro Boost Water Gel',
//       price: 18.75,
//       image:
//           'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?auto=format&fit=crop&w=500&q=80',
//       description:
//           'Oil-free water gel moisturizer with hyaluronic acid that provides intense hydration without heaviness.',
//     ),
//   ];

//   List<Widget> get _screens => [
//     HomeContent(products: products),
//     const CartScreen(),
//     const ProfileScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     cartState.addListener(() => setState(() {}));
//   }

//   @override
//   void dispose() {
//     cartState.removeListener(() {});
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 280),
//           transitionBuilder: (child, animation) => FadeTransition(
//             opacity: animation,
//             child: SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(0, 0.03),
//                 end: Offset.zero,
//               ).animate(animation),
//               child: child,
//             ),
//           ),
//           child: KeyedSubtree(
//             key: ValueKey<int>(selectedIndex),
//             child: _screens[selectedIndex],
//           ),
//         ),
//       ),
//       bottomNavigationBar: AnimatedBottomNav(
//         currentIndex: selectedIndex,
//         onTap: (index) => setState(() => selectedIndex = index),
//         cartCount: cartState.totalItems,
//         items: const [
//           _NavItemData(
//             icon: Icons.home_outlined,
//             activeIcon: Icons.home,
//             label: 'Home',
//           ),
//           _NavItemData(
//             icon: Icons.shopping_bag_outlined,
//             activeIcon: Icons.shopping_bag,
//             label: 'Cart',
//           ),
//           _NavItemData(
//             icon: Icons.person_outline,
//             activeIcon: Icons.person,
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ================================================================
// // ANIMATED BOTTOM NAVIGATION
// // ================================================================
// class _NavItemData {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;

//   const _NavItemData({
//     required this.icon,
//     required this.activeIcon,
//     required this.label,
//   });
// }

// class AnimatedBottomNav extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   final List<_NavItemData> items;
//   final int cartCount;

//   const AnimatedBottomNav({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     required this.items,
//     this.cartCount = 0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 68,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.grey.shade200)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: List.generate(items.length, (index) {
//           final selected = index == currentIndex;
//           final item = items[index];
//           return GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () => onTap(index),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 260),
//               curve: Curves.easeOutCubic,
//               padding: EdgeInsets.symmetric(
//                 horizontal: selected ? 18 : 12,
//                 vertical: 8,
//               ),
//               decoration: BoxDecoration(
//                 color: selected ? Colors.black : Colors.transparent,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 220),
//                         transitionBuilder: (child, anim) =>
//                             ScaleTransition(scale: anim, child: child),
//                         child: Icon(
//                           selected ? item.activeIcon : item.icon,
//                           key: ValueKey<bool>(selected),
//                           size: 22,
//                           color: selected ? Colors.white : Colors.grey.shade500,
//                         ),
//                       ),
//                       if (index == 1 && cartCount > 0)
//                         Positioned(
//                           right: -6,
//                           top: -4,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Color(0xFF42B927),
//                               shape: BoxShape.circle,
//                             ),
//                             constraints: const BoxConstraints(
//                               minWidth: 16,
//                               minHeight: 16,
//                             ),
//                             child: Text(
//                               cartCount > 9 ? '9+' : '$cartCount',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   AnimatedSize(
//                     duration: const Duration(milliseconds: 220),
//                     curve: Curves.easeOutCubic,
//                     child: selected
//                         ? Padding(
//                             padding: const EdgeInsets.only(left: 6),
//                             child: Text(
//                               item.label,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           )
//                         : const SizedBox.shrink(),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// // ================================================================
// // HOME CONTENT
// // ================================================================
// class HomeContent extends StatelessWidget {
//   final List<Product> products;

//   const HomeContent({super.key, required this.products});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 12, bottom: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _header(context),
//             const SizedBox(height: 18),
//             _promotionBanner(),
//             const SizedBox(height: 26),
//             _sectionTitle(title: 'Categories', action: 'See all'),
//             const SizedBox(height: 12),
//             _categories(),
//             const SizedBox(height: 26),
//             _sectionTitle(title: 'New arrivals', action: 'See all'),
//             const SizedBox(height: 12),
//             _productsGrid(context),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _header(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.black.withOpacity(.6),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 const Text(
//                   'Olivia',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     height: 1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 44,
//             height: 44,
//             decoration: const BoxDecoration(
//               color: Color(0xFFF5F5F5),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.search, size: 21, color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _promotionBanner() {
//     return SizedBox(
//       height: 195,
//       child: ListView(
//         padding: const EdgeInsets.only(left: 18),
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         children: [
//           _promoCard(
//             width: 300,
//             background: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFFB3EE7D), Color(0xFF62CC32)],
//             ),
//             brand: 'Murad',
//             title: 'Retinol Youth\nRenewal Night Cream',
//             description:
//                 'Retinol Tri-Active Technology\nvisibly lifts, firms & smooths\novernight.',
//             discount: '20% OFF',
//             image:
//                 'https://images.unsplash.com/photo-1611930022073-b7a4ba5fcccd?auto=format&fit=crop&w=700&q=85',
//             textColor: const Color(0xFF0A4D15),
//           ),
//           const SizedBox(width: 14),
//           _promoCard(
//             width: 300,
//             background: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFFD8CDC7), Color(0xFFB9ADA6)],
//             ),
//             brand: 'Murad',
//             title: 'Retinol Youth\nRenewal Night Cream',
//             description:
//                 'Retinol Tri-Active Technology\nvisibly lifts, firms & smooths\novernight.',
//             discount: '10% OFF',
//             image:
//                 'https://images.unsplash.com/photo-1611930022073-b7a4ba5fcccd?auto=format&fit=crop&w=700&q=85',
//             textColor: const Color(0xFF3D3430),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _promoCard({
//     required double width,
//     required LinearGradient background,
//     required String brand,
//     required String title,
//     required String description,
//     required String discount,
//     required String image,
//     required Color textColor,
//   }) {
//     return Container(
//       width: width,
//       padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
//       decoration: BoxDecoration(
//         gradient: background,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Stack(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 brand,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 17,
//                   height: 1.15,
//                   fontWeight: FontWeight.w700,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 description,
//                 style: TextStyle(
//                   fontSize: 10.5,
//                   height: 1.35,
//                   color: textColor.withOpacity(.85),
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(.45),
//                   borderRadius: BorderRadius.circular(30),
//                   border: Border.all(color: Colors.white.withOpacity(.5)),
//                 ),
//                 child: Text(
//                   discount,
//                   style: TextStyle(
//                     color: textColor,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 11,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             right: -18,
//             bottom: 0,
//             child: SizedBox(
//               width: 110,
//               height: 150,
//               child: Image.network(
//                 image,
//                 fit: BoxFit.contain,
//                 errorBuilder: (_, __, ___) {
//                   return const Icon(Icons.spa, size: 60, color: Colors.white);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _sectionTitle({required String title, required String action}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       child: Row(
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//           ),
//           const Spacer(),
//           Text(
//             action,
//             style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _categories() {
//     final categories = [
//       CategoryItem(title: 'Fragrance', icon: Icons.local_florist_outlined),
//       CategoryItem(
//         title: 'Makeup',
//         icon: Icons.face_retouching_natural_outlined,
//       ),
//       CategoryItem(title: 'Hair', icon: Icons.content_cut),
//       CategoryItem(title: 'Skincare', icon: Icons.inventory_2_outlined),
//     ];

//     return SizedBox(
//       height: 42,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 18),
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 10),
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(30),
//               border: Border.all(color: Colors.grey.shade200, width: 1.2),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(.03),
//                   blurRadius: 8,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Icon(category.icon, size: 16, color: Colors.black),
//                 const SizedBox(width: 6),
//                 Text(
//                   category.title,
//                   style: const TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _productsGrid(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: products.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 14,
//           crossAxisSpacing: 14,
//           childAspectRatio: 0.62,
//         ),
//         itemBuilder: (context, index) {
//           return AnimatedProductEntry(
//             index: index,
//             child: ProductCard(
//               product: products[index],
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         ProductDetailScreen(product: products[index]),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ================================================================
// // STAGGERED FADE/SLIDE-IN
// // ================================================================
// class AnimatedProductEntry extends StatefulWidget {
//   final int index;
//   final Widget child;

//   const AnimatedProductEntry({
//     super.key,
//     required this.index,
//     required this.child,
//   });

//   @override
//   State<AnimatedProductEntry> createState() => _AnimatedProductEntryState();
// }

// class _AnimatedProductEntryState extends State<AnimatedProductEntry>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _fade;
//   late final Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 420),
//     );
//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.08),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
//     final delay = Duration(milliseconds: 60 * (widget.index % 6));
//     Future.delayed(delay, () {
//       if (mounted) _controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fade,
//       child: SlideTransition(position: _slide, child: widget.child),
//     );
//   }
// }

// // ================================================================
// // PRODUCT CARD
// // ================================================================
// class ProductCard extends StatefulWidget {
//   final Product product;
//   final VoidCallback? onTap;

//   const ProductCard({super.key, required this.product, this.onTap});

//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {
//   bool favorite = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(.035),
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'NEW',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 8.5,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: () => setState(() => favorite = !favorite),
//                   child: AnimatedScale(
//                     scale: favorite ? 1.15 : 1.0,
//                     duration: const Duration(milliseconds: 200),
//                     curve: Curves.easeOutBack,
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 200),
//                       transitionBuilder: (child, anim) =>
//                           ScaleTransition(scale: anim, child: child),
//                       child: Icon(
//                         favorite ? Icons.favorite : Icons.favorite_border,
//                         key: ValueKey<bool>(favorite),
//                         size: 20,
//                         color: favorite
//                             ? const Color(0xFF42B927)
//                             : Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 6,
//                   ),
//                   child: Image.network(
//                     widget.product.image,
//                     fit: BoxFit.contain,
//                     errorBuilder: (_, __, ___) {
//                       return const Icon(
//                         Icons.spa_outlined,
//                         size: 56,
//                         color: Colors.grey,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             Text(
//               widget.product.brand,
//               style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 3),
//             Text(
//               widget.product.name,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 13,
//                 height: 1.2,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Divider(color: Colors.grey.shade200, height: 1),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     '\$${widget.product.price.toStringAsFixed(2)}',
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 _AnimatedAddButton(
//                   onAdd: () {
//                     cartState.add(widget.product);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('${widget.product.name} added'),
//                         duration: const Duration(milliseconds: 900),
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ================================================================
// // ANIMATED ADD BUTTON
// // ================================================================
// class _AnimatedAddButton extends StatefulWidget {
//   final VoidCallback onAdd;

//   const _AnimatedAddButton({required this.onAdd});

//   @override
//   State<_AnimatedAddButton> createState() => _AnimatedAddButtonState();
// }

// class _AnimatedAddButtonState extends State<_AnimatedAddButton> {
//   bool pressed = false;
//   bool added = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => pressed = true),
//       onTapCancel: () => setState(() => pressed = false),
//       onTapUp: (_) {
//         setState(() {
//           pressed = false;
//           added = true;
//         });
//         widget.onAdd();
//         Future.delayed(const Duration(milliseconds: 900), () {
//           if (mounted) setState(() => added = false);
//         });
//       },
//       child: AnimatedScale(
//         scale: pressed ? 0.88 : 1.0,
//         duration: const Duration(milliseconds: 120),
//         child: Container(
//           width: 34,
//           height: 34,
//           decoration: BoxDecoration(
//             color: added ? const Color(0xFF42B927) : Colors.black,
//             shape: BoxShape.circle,
//           ),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 220),
//             transitionBuilder: (child, anim) =>
//                 ScaleTransition(scale: anim, child: child),
//             child: Icon(
//               added ? Icons.check : Icons.add,
//               key: ValueKey<bool>(added),
//               color: Colors.white,
//               size: 20,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ================================================================
// // PRODUCT DETAILS PAGE
// // ================================================================
// class ProductDetailScreen extends StatefulWidget {
//   final Product product;

//   const ProductDetailScreen({super.key, required this.product});

//   @override
//   State<ProductDetailScreen> createState() => _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends State<ProductDetailScreen> {
//   int quantity = 1;
//   bool favorite = false;

//   @override
//   Widget build(BuildContext context) {
//     final product = widget.product;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // App bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: () => setState(() => favorite = !favorite),
//                     icon: Icon(
//                       favorite ? Icons.favorite : Icons.favorite_border,
//                       color: favorite ? const Color(0xFF42B927) : Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Image
//             Expanded(
//               flex: 5,
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Image.network(
//                     product.image,
//                     fit: BoxFit.contain,
//                     errorBuilder: (_, __, ___) => const Icon(
//                       Icons.spa_outlined,
//                       size: 120,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Details card
//             Expanded(
//               flex: 6,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(32),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.06),
//                       blurRadius: 20,
//                       offset: const Offset(0, -4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       product.brand,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       product.name,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         height: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       '\$${product.price.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF42B927),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       product.description,
//                       style: TextStyle(
//                         fontSize: 14,
//                         height: 1.5,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     const Spacer(),

//                     // Quantity + Add to Cart
//                     Row(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF5F5F5),
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: Row(
//                             children: [
//                               IconButton(
//                                 onPressed: quantity > 1
//                                     ? () => setState(() => quantity--)
//                                     : null,
//                                 icon: const Icon(Icons.remove, size: 18),
//                               ),
//                               Text(
//                                 '$quantity',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () => setState(() => quantity++),
//                                 icon: const Icon(Icons.add, size: 18),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               cartState.add(product, qty: quantity);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     '${product.name} × $quantity added to cart',
//                                   ),
//                                   behavior: SnackBarBehavior.floating,
//                                   duration: const Duration(milliseconds: 1200),
//                                 ),
//                               );
//                               Navigator.pop(context);
//                             },
//                             child: Container(
//                               height: 52,
//                               decoration: BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               alignment: Alignment.center,
//                               child: const Text(
//                                 'Add to Cart',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ================================================================
// // CART PAGE
// // ================================================================
// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   @override
//   void initState() {
//     super.initState();
//     cartState.addListener(_onCartChanged);
//   }

//   @override
//   void dispose() {
//     cartState.removeListener(_onCartChanged);
//     super.dispose();
//   }

//   void _onCartChanged() => setState(() {});

//   @override
//   Widget build(BuildContext context) {
//     final items = cartState.items;

//     if (items.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.shopping_bag_outlined,
//               size: 72,
//               color: Colors.grey.shade300,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Your cart is empty',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Add some beauty products',
//               style: TextStyle(color: Colors.grey.shade500),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
//           child: Row(
//             children: [
//               const Text(
//                 'My Cart',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
//               ),
//               const Spacer(),
//               Text(
//                 '${cartState.totalItems} items',
//                 style: TextStyle(color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//             itemCount: items.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 14),
//             itemBuilder: (context, index) {
//               final item = items[index];
//               return _CartItemTile(item: item);
//             },
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 12,
//                 offset: const Offset(0, -4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   const Text(
//                     'Total',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '\$${cartState.totalPrice.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Checkout coming soon!'),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 54,
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Checkout',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _CartItemTile extends StatelessWidget {
//   final CartItem item;

//   const _CartItemTile({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     final product = item.product;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               width: 72,
//               height: 72,
//               color: const Color(0xFFF8F8F8),
//               child: Image.network(
//                 product.image,
//                 fit: BoxFit.contain,
//                 errorBuilder: (_, __, ___) =>
//                     const Icon(Icons.spa_outlined, color: Colors.grey),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.brand,
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   product.name,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   '\$${product.price.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               Row(
//                 children: [
//                   _qtyButton(
//                     icon: Icons.remove,
//                     onTap: () =>
//                         cartState.updateQuantity(product, item.quantity - 1),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Text(
//                       '${item.quantity}',
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   _qtyButton(
//                     icon: Icons.add,
//                     onTap: () =>
//                         cartState.updateQuantity(product, item.quantity + 1),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () => cartState.remove(product),
//                 child: Text(
//                   'Remove',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.red.shade400,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 28,
//         height: 28,
//         decoration: BoxDecoration(
//           color: const Color(0xFFF5F5F5),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, size: 16),
//       ),
//     );
//   }
// }

// // ================================================================
// // PROFILE PAGE (simple)
// // ================================================================
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
//       child: Column(
//         children: [
//           const SizedBox(height: 20),
//           CircleAvatar(
//             radius: 48,
//             backgroundColor: Colors.grey.shade200,
//             child: const Icon(Icons.person, size: 48, color: Colors.grey),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Olivia',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'olivia@beautystore.com',
//             style: TextStyle(color: Colors.grey.shade600),
//           ),
//           const SizedBox(height: 32),
//           _profileTile(Icons.shopping_bag_outlined, 'My Orders'),
//           _profileTile(Icons.favorite_border, 'Wishlist'),
//           _profileTile(Icons.location_on_outlined, 'Addresses'),
//           _profileTile(Icons.payment_outlined, 'Payment Methods'),
//           _profileTile(Icons.settings_outlined, 'Settings'),
//           _profileTile(Icons.help_outline, 'Help & Support'),
//           const SizedBox(height: 24),
//           TextButton(
//             onPressed: () {},
//             child: const Text(
//               'Log out',
//               style: TextStyle(color: Colors.red, fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _profileTile(IconData icon, String title) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.black87),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
//         trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//         onTap: () {},
//       ),
//     );
//   }
// }

// // ================================================================
// // MODELS
// // ================================================================
// class Product {
//   final String brand;
//   final String name;
//   final double price;
//   final String image;
//   final String description;

//   Product({
//     required this.brand,
//     required this.name,
//     required this.price,
//     required this.image,
//     this.description = '',
//   });
// }

// class CategoryItem {
//   final String title;
//   final IconData icon;

//   CategoryItem({required this.title, required this.icon});
// }
