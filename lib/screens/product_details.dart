// import 'package:clothing_shop/models/product_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ProductDetails extends StatelessWidget {
//   final String productId;

//   const ProductDetails({super.key, required this.productId});

//   Future<ProductModel?> getProducts() async {
//     final document = await FirebaseFirestore.instance
//         .collection("products")
//         .doc(productId)
//         .get();

//     if (!document.exists) {
//       return null;
//     }

//     return ProductModel.fromMap(document.data()!, document.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           "Product Details",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//       ),

//       body: FutureBuilder<ProductModel?>(
//         future: getProducts(),

//         builder: (context, snapshot) {
//           // Loading
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Colors.blue),
//             );
//           }

//           // Error
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }

//           // No data
//           if (!snapshot.hasData || snapshot.data == null) {
//             return const Center(
//               child: Text(
//                 "No product found",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             );
//           }

//           final product = snapshot.data!;

//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // =========================
//                 // PRODUCT BANNER
//                 // =========================
//                 Container(
//                   margin: const EdgeInsets.all(16),
//                   height: 420,
//                   width: double.infinity,

//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(25),
//                     gradient: const LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [Color(0xff1E1E1E), Color(0xff3A3A3A)],
//                     ),

//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 15,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),

//                   child: Stack(
//                     children: [
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         bottom: 0,
//                         child: ClipRRect(
//                           borderRadius: const BorderRadius.only(
//                             topRight: Radius.circular(25),
//                             bottomRight: Radius.circular(25),
//                           ),
//                           child: SizedBox(
//                             width: 190,
//                             child: Image.network(
//                               "",
//                               fit: BoxFit.cover,

//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   color: Colors.grey.shade300,
//                                   child: const Icon(
//                                     Icons.image_not_supported,
//                                     size: 50,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),

//                       // =========================
//                       // GRADIENT OVER IMAGE
//                       // =========================
//                       Positioned(
//                         right: 130,
//                         top: 0,
//                         bottom: 0,
//                         width: 100,
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [Color(0xff1E1E1E), Colors.transparent],
//                             ),
//                           ),
//                         ),
//                       ),

//                       // =========================
//                       // TEXT CONTENT
//                       // =========================
//                       Positioned(
//                         left: 25,
//                         top: 35,
//                         right: 150,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Small label
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Text(
//                                 "NEW",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 20),

//                             // Title
//                             Text(
//                               product.title,
//                               maxLines: 3,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 30,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(height: 15),

//                             // Description
//                             Text(
//                               product.description,
//                               maxLines: 5,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.75),
//                                 fontSize: 14,
//                                 height: 1.5,
//                               ),
//                             ),

//                             const SizedBox(height: 25),

//                             // Price
//                             Text(
//                               "Rs. ${product.price.toStringAsFixed(2)}",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // =========================
//                 // PRODUCT INFORMATION
//                 // =========================
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Product Details",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       Text(
//                         product.description,
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.grey.shade700,
//                           height: 1.6,
//                         ),
//                       ),

//                       const SizedBox(height: 25),

//                       // =========================
//                       // PRICE + ORDER BUTTON
//                       // =========================
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Price",
//                                   style: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 14,
//                                   ),
//                                 ),

//                                 const SizedBox(height: 5),

//                                 Text(
//                                   "Rs. ${product.price.toStringAsFixed(2)}",
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           ElevatedButton(
//                             onPressed: () {
//                               // Order logic here
//                             },

//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 25,
//                                 vertical: 15,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                             ),

//                             child: const Text(
//                               "Order Now",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 30),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
