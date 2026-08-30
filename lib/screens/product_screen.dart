// import 'package:clothing_shop/models/product_model.dart';
// import 'package:clothing_shop/providers/product_provider.dart';
// import 'package:clothing_shop/screens/product_details.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ProductScreen extends StatefulWidget {
//   const ProductScreen({super.key});

//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }

// class _ProductScreenState extends State<ProductScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ProductProvider>().fetchproducts();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Products'), centerTitle: true),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showProductDialog(context);
//         },
//         child: const Icon(Icons.add),
//       ),

//       body: Consumer<ProductProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading && provider.products.isEmpty) {
//             return const Center(
//               child: CircularProgressIndicator(color: Colors.blue),
//             );
//           }

//           if (provider.products.isEmpty) {
//             return const Center(
//               child: Text('No products found', style: TextStyle(fontSize: 18)),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: provider.products.length,
//             itemBuilder: (context, index) {
//               final product = provider.products[index];

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: ListTile(
//                   title: Text(
//                     product.title,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),

//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 5),
//                       Text(product.description),
//                       const SizedBox(height: 5),
//                       Text(
//                         'Rs. ${product.price.toStringAsFixed(2)}',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),

//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.details, color: Colors.blue),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   ProductDetails(productId: product.id),
//                             ),
//                           );
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.edit, color: Colors.blue),
//                         onPressed: () {
//                           showProductDialog(context, product: product);
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           showDeleteDialog(context, product);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// void showProductDialog(BuildContext context, {ProductModel? product}) {
//   final titleController = TextEditingController(text: product?.title ?? '');

//   final descriptionController = TextEditingController(
//     text: product?.description ?? '',
//   );

//   final priceController = TextEditingController(
//     text: product != null ? product.price.toString() : '',
//   );

//   final isEdit = product != null;

//   showDialog(
//     context: context,
//     builder: (dialogContext) {
//       return StatefulBuilder(
//         builder: (dialogContext, setDialogState) {
//           bool isSubmitting = false;

//           Future<void> handleSubmit() async {
//             final title = titleController.text.trim();
//             final description = descriptionController.text.trim();
//             final price = double.tryParse(priceController.text.trim());

//             if (title.isEmpty || description.isEmpty || price == null) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Please enter valid product details'),
//                 ),
//               );
//               return;
//             }

//             final provider = context.read<ProductProvider>();

//             setDialogState(() => isSubmitting = true);

//             try {
//               if (isEdit) {
//                 await provider.updateProduct(
//                   id: product.id,
//                   title: title,
//                   description: description,
//                   price: price,
//                 );
//               } else {
//                 await provider.addProduct(
//                   title: title,
//                   description: description,
//                   price: price,
//                 );
//               }

//               if (dialogContext.mounted) {
//                 Navigator.pop(dialogContext);
//               }
//             } catch (e) {
//               setDialogState(() => isSubmitting = false);
//               if (dialogContext.mounted) {
//                 ScaffoldMessenger.of(
//                   dialogContext,
//                 ).showSnackBar(SnackBar(content: Text(e.toString())));
//               }
//             }
//           }

//           return AlertDialog(
//             title: Text(isEdit ? 'Edit Product' : 'Add Product'),

//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: titleController,
//                     decoration: const InputDecoration(
//                       labelText: 'Title',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   TextField(
//                     controller: descriptionController,
//                     maxLines: 3,
//                     decoration: const InputDecoration(
//                       labelText: 'Description',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   TextField(
//                     controller: priceController,
//                     keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true,
//                     ),
//                     decoration: const InputDecoration(
//                       labelText: 'Price',
//                       border: OutlineInputBorder(),
//                       prefixText: 'Rs. ',
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             actions: [
//               TextButton(
//                 onPressed: isSubmitting
//                     ? null
//                     : () => Navigator.pop(dialogContext),
//                 child: const Text('Cancel'),
//               ),

//               ElevatedButton(
//                 onPressed: isSubmitting ? null : handleSubmit,
//                 child: isSubmitting
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : Text(isEdit ? 'Update' : 'Add'),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }

// void showDeleteDialog(BuildContext context, ProductModel product) {
//   showDialog(
//     context: context,
//     builder: (dialogContext) {
//       return AlertDialog(
//         title: const Text('Delete Product'),
//         content: Text('Are you sure you want to delete "${product.title}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             onPressed: () async {
//               try {
//                 await context.read<ProductProvider>().deleteProduct(product.id);
//                 if (dialogContext.mounted) {
//                   Navigator.pop(dialogContext);
//                 }
//               } catch (e) {
//                 if (dialogContext.mounted) {
//                   ScaffoldMessenger.of(
//                     dialogContext,
//                   ).showSnackBar(SnackBar(content: Text(e.toString())));
//                 }
//               }
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       );
//     },
//   );
// }
