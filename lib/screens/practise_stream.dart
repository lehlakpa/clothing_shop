// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import '../models/product_model.dart';

// class PractiseStream extends StatelessWidget {
//   const PractiseStream({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Products')),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: FirebaseFirestore.instance.collection('products').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(child: Text('Something went wrong'));
//           }
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final products = snapshot.data!.docs
//               .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
//               .toList();
//           if (products.isEmpty) {
//             return const Center(child: Text('No products found'));
//           }

//           return ListView.builder(
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index];
//               return ListTile(
//                 title: Text(product.name),
//                 subtitle: Text(product.description),
//                 trailing: Text('Rs. ${product.price.toStringAsFixed(2)}'),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
