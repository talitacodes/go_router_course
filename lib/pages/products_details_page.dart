import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_course/core/events.dart';
import 'package:go_router_course/core/router.dart';
import 'package:go_router_course/main.dart';

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
      appBar: AppBar(
        title: Text('Detalhes do Produto ${widget.id}'),
        actions: [
          IconButton(
              onPressed: () {
                eventBus.fire(ProductFavoriteChanged(widget.id, true));
              },
              icon: Icon(Icons.favorite_rounded))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => context.go('/products'),
                child: const Text("Ir para home")),
            OutlinedButton(
                onPressed: () => context.go('/cart'),
                child: const Text('Adicionar ao carrinho')),
            ElevatedButton(
                onPressed: () => changeRoutes(false),
                child: const Text("Desabilitar detalhes do produto")),
          ],
        ),
      ),
    );
  }
}
