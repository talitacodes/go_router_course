import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_course/main.dart';
import 'package:go_router_course/pages/cart_page.dart';
import 'package:go_router_course/pages/dialog_page.dart';
import 'package:go_router_course/pages/login_page.dart';
import 'package:go_router_course/pages/not_found_page.dart';
import 'package:go_router_course/pages/products_details_page.dart';
import 'package:go_router_course/repositories/auth_repository.dart';

//Usar a mesma pagina para varias rotas, nao precisa ser sempre 1:1

final authRepository = AuthRepository();

final router = GoRouter(
  redirect: (context, state) {
    if (state.fullPath == '/cart' && !authRepository.isLoggedIn) {
      return '/login';
    }
    return null;
  },
  debugLogDiagnostics: true,
  redirectLimit: 5,
  errorBuilder: (_, state) => NotFoundPage(),
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const MyHomePage(),
      routes: [
        GoRoute(
            path: 'cart',
            builder: (_, state) => CartPage(),
            redirect: (_, state) =>
                processGuards(state, [LoggedInRouteGuard()])),
        GoRoute(
            path: 'login',
            builder: (_, state) => LoginPage(
                  redirectTo: state.uri.queryParameters['redirectTo'],
                )),
        GoRoute(
            path: 'login-dialog',
            pageBuilder: (context, state) => DialogPage(
                builder: (_) => Dialog(), barrierDismissible: false)),
        GoRoute(
            path: 'products',
            builder: (_, state) => ProductsListPage(
                page:
                    int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 0),
            routes: [
              GoRoute(
                  path: ':id',
                  builder: (context, state) => ProductsDetailsPage(
                      id: int.tryParse(state.pathParameters['id']!) ?? 0),
                  onExit: (context, state) {
                    //return false; nao deixa sair
                    return true;
                  },
                  redirect: (_, state) =>
                      processGuards(state, [LoggedInRouteGuard()]))
            ])
      ],
    ),
  ],
);

String? processGuards(GoRouterState state, List<RouteGuard> guards) {
  for (final g in guards) {
    final result = g.verify(state);
    if (result != null) return result;
  }
  return null;
}

abstract interface class RouteGuard {
  String? verify(GoRouterState state);
}

class LoggedInRouteGuard implements RouteGuard {
  @override
  String? verify(GoRouterState state) {
    if (!authRepository.isLoggedIn) {
      return '/login?redirectTo=${state.matchedLocation}';
    }
    return null;
  }
}

class PremiumUserRouteGuard implements RouteGuard {
  @override
  String? verify(GoRouterState state) {
    if (!authRepository.loggedUser!.premium) {
      return '/buy-premium';
    }
    return null;
  }
}
