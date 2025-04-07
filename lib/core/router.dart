import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_course/pages/cart_page.dart';
import 'package:go_router_course/pages/dialog_page.dart';
import 'package:go_router_course/pages/home_page.dart';
import 'package:go_router_course/pages/login_page.dart';
import 'package:go_router_course/pages/not_found_page.dart';
import 'package:go_router_course/pages/products_details_page.dart';
import 'package:go_router_course/pages/products_list_page.dart';
import 'package:go_router_course/repositories/auth_repository.dart';

//Usar a mesma pagina para varias rotas, nao precisa ser sempre 1:1

final authRepository = AuthRepository();

final rootNavigator = GlobalKey<NavigatorState>();

final router = GoRouter(
  redirect: (context, state) {
    /*if (state.fullPath == '/cart' && !authRepository.isLoggedIn) {
      return '/login';
    }*/
    return null;
  },
  debugLogDiagnostics: true,
  redirectLimit: 5,
  //errorBuilder: (_, state) => NotFoundPage(),
  onException: (_, state, router) {
    // o errorBuilder para de funcionar se for utilizado o metodo onException
    router.go('404');
    print('Exception');
  },
  initialLocation: '/products',
  navigatorKey: rootNavigator,
  routes: [
    GoRoute(path: '404', builder: (_, state) => NotFoundPage()),
    GoRoute(
        path: '/login',
        builder: (_, state) => LoginPage(
              redirectTo: state.uri.queryParameters['redirectTo'],
            )),
    GoRoute(
        path: '/login-dialog',
        pageBuilder: (context, state) =>
            DialogPage(builder: (_) => Dialog(), barrierDismissible: false)),
    StatefulShellRoute.indexedStack(
        //Solucao para nao precisar usar pageBuilder
        builder: (context, state, shell) => MyHomePage(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/products',
                builder: (_, state) => ProductsListPage(
                    page:
                        int.tryParse(state.uri.queryParameters['page'] ?? '') ??
                            0),
                routes: [
                  GoRoute(
                      path: ':id',
                      parentNavigatorKey: rootNavigator,
                      builder: (context, state) => ProductsDetailsPage(
                          id: int.tryParse(state.pathParameters['id']!) ?? 0),
                      onExit: (context, state) {
                        //return false; nao deixa sair
                        return true;
                      },
                      redirect: (_, state) => processGuards(state, [
                            LoggedInRouteGuard(),
                            ValidIntParametersGuard(['id'])
                          ]))
                ])
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/cart',
                pageBuilder: (context, state) => NoTransitionPage(
                    child: CartPage()), //Tirar animacao entre as telas
                redirect: (_, state) =>
                    processGuards(state, [LoggedInRouteGuard()])),
          ]),
        ]),
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

class ValidIntParametersGuard implements RouteGuard {
  ValidIntParametersGuard(this.params);

  final List<String> params;
  @override
  String? verify(GoRouterState state) {
    for (final p in params) {
      final id = state.pathParameters['p'];
      final parsedId = int.tryParse(id ?? '');
      if (parsedId == null) {
        return '/404';
      }
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
