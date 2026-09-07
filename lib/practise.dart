import 'dart:convert';

import 'package:clothing_shop/models/product.dart';
import 'package:clothing_shop/practise_screens/practise_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Practise extends StatefulWidget {
  const Practise({super.key});

  @override
  State<Practise> createState() => _PractiseState();
}

class _PractiseState extends State<Practise> {
  @override
  Widget build(BuildContext context) {
    final GetData = context.read<PractiseProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: FutureBuilder<List<Product>>(
        future: GetData.getProducts(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          // 4. Success
          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                leading: Image.network(
                  product.thumbnail,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                title: Text(product.title),
                subtitle: Text("\$${product.price}"),
              );
            },
          );
        },
      ),
    );
  }
}
