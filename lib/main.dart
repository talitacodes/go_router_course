import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:go_router_course/core/router.dart';
import 'package:url_strategy/url_strategy.dart';

final eventBus = EventBus();

void main() {
  setPathUrlStrategy(); //altera url sem precisar usar #, sem recarregar varias requisiçoes pro servidor
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RouteObserver(
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Flutter Demo',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true),
      ),
    );
  }
}

class RouteObserver extends StatefulWidget {
  final Widget child;
  const RouteObserver({super.key, required this.child});

  @override
  State<RouteObserver> createState() => _RouteObserverState();
}

class _RouteObserverState extends State<RouteObserver> {
  String? lastRoute;
  Stopwatch routeStopwatch = Stopwatch();
  @override
  void initState() {
    super.initState();

    router.routerDelegate.addListener(_handleRouteChange);
  }

  @override
  void dispose() {
    super.dispose();

    router.routerDelegate.removeListener(_handleRouteChange);
  }

  void _handleRouteChange() {
    if (lastRoute != null) {
      print(
          '$lastRoute ${routeStopwatch.elapsed}'); //Quanto tempo o usuario passou em cada tela
    }

    routeStopwatch.reset();
    routeStopwatch.start();

    final config = router.routerDelegate.currentConfiguration;
    final path = config.fullPath;
    final pathParameters = config.pathParameters;
    final queryParameters = config.uri.queryParameters;

    lastRoute = path;
    print('ROUTE $path $pathParameters $queryParameters');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
