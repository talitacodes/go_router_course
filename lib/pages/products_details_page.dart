import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsDetailsPage extends StatefulWidget {
  final int id;
  const ProductsDetailsPage({super.key, required this.id});

  @override
  State<ProductsDetailsPage> createState() => _ProductsDetailsPageState();
}

class _ProductsDetailsPageState extends State<ProductsDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(title: Text('Detalhes do Produto ${widget.id}')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text("Ir para home")),
            OutlinedButton(
                onPressed: () => context.go('/cart'),
                child: const Text('Adicionar ao carrinho'))
          ],
        ),
      ),
    );
  }
}
