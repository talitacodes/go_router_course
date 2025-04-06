import 'package:flutter/material.dart';

class DialogPage extends Page {
  final WidgetBuilder builder;
  final bool barrierDismissible;
  const DialogPage({required this.builder, this.barrierDismissible = true});

  @override
  Route createRoute(BuildContext context) {
    return DialogRoute(
        context: context,
        settings: this,
        builder: builder,
        barrierDismissible: barrierDismissible);
  }
}
