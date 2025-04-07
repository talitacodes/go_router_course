import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: widget.shell,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Produtos'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Carrinho')
        ],
        currentIndex: widget.shell.currentIndex,
        onTap: (i) {
          widget.shell
              .goBranch(i, initialLocation: i == widget.shell.currentIndex);
        },
      ),
    );
  }
}
