import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_course/core/events.dart';
import 'package:go_router_course/core/router.dart';
import 'package:go_router_course/main.dart';

class ProductsListPage extends StatefulWidget {
  final int page;
  const ProductsListPage({super.key, required this.page});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  StreamSubscription? subscription;
  @override
  void initState() {
    super.initState();
    subscription = eventBus.on<ProductFavoriteChanged>().listen((event) {
      print('ProductFavoriteChanged: ${event.id} ${event.isFavorite}');
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(title: Text('Lista de Produtos Page ${widget.page}')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  // context.goNamed(AppRoutes.productDetails.name,
                  //     pathParameters: {'id': '123'},
                  //     queryParameters: {'search': 'camisa'});
                  context.go('/products/123');
                },
                child: const Text('Ir para detalhes do produto')),
            ElevatedButton(
                onPressed: () {
                  changeRoutes(true);
                },
                child: const Text('Habilitar detalhes do produto')),
          ],
        ),
      ),
    );
  }
}
