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

//Passar dados primitivos entre as rotas

//Usar a mesma pagina para varias rotas, nao precisa ser sempre 1:1

final authRepository = AuthRepository();

final rootNavigator = GlobalKey<NavigatorState>();

class AuthManager extends ChangeNotifier {}

class CartManager extends ChangeNotifier {}

enum AppRoutes { productDetails, login, productList }

bool splashDone = false;

RoutingConfig getRoutingConfig(bool enableProductDetails) {
  return RoutingConfig(
    redirect: (context, state) {
      // if (!splashDone) {
      //   //Deeplink
      //   return '/splash?redirectTo=${state.matchedLocation}';
      // }
      /*if (state.fullPath == '/cart' && !authRepository.isLoggedIn) {
      return '/login';
    }*/
      return null;
    },
    redirectLimit: 5,
    routes: [
      GoRoute(
          name: 'error',
          path: '404',
          pageBuilder: (_, state) =>
              CustomPage(state: state, child: NotFoundPage())),
      GoRoute(
          name: AppRoutes.login.name,
          path: '/login',
          pageBuilder: (_, state) => CustomPage(
              state: state,
              child: LoginPage(
                  redirectTo: state.uri.queryParameters['redirectTo']))),
      GoRoute(
          path: '/login-dialog',
          pageBuilder: (context, state) =>
              DialogPage(builder: (_) => Dialog(), barrierDismissible: false)),
      StatefulShellRoute.indexedStack(
          //Abas
          //Solucao para nao precisar usar pageBuilder
          pageBuilder: (context, state, shell) =>
              CustomPage(state: state, child: MyHomePage(shell: shell)),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  name: AppRoutes.productList.name, //para usar com goNamed
                  path: '/products',
                  pageBuilder: (_, state) => CustomPage(
                        state: state,
                        child: ProductsListPage(
                            page: int.tryParse(
                                    state.uri.queryParameters['page'] ?? '') ??
                                0),
                      ),
                  routes: [
                    if (enableProductDetails)
                      GoRoute(
                          name: AppRoutes.productDetails.name,
                          path: ':id',
                          parentNavigatorKey: rootNavigator,
                          pageBuilder: (context, state) => CustomPage(
                                state: state,
                                child: ProductsDetailsPage(
                                    id: int.tryParse(
                                            state.pathParameters['id']!) ??
                                        0),
                              ),
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
                  pageBuilder: (context, state) =>
                      CustomPage(state: state, child: CartPage()),
                  redirect: (_, state) =>
                      processGuards(state, [LoggedInRouteGuard()])),
            ]),
          ]),
    ],
  );
}

//Níveis de acesso do usuário: por exemplo premium: rotas dinamicas
final ValueNotifier<RoutingConfig> myRoutingConfig =
    ValueNotifier<RoutingConfig>(getRoutingConfig(false));

void changeRoutes(bool enableProductDetails) {
  myRoutingConfig.value = getRoutingConfig(enableProductDetails);
}

final router = GoRouter.routingConfig(
  routingConfig: myRoutingConfig,
  refreshListenable: Listenable.merge([AuthManager(), CartManager()]),
  //errorBuilder: (_, state) => NotFoundPage(),
  onException: (_, state, router) {
    // o errorBuilder para de funcionar se for utilizado o metodo onException
    router.go('404');
    print('Exception');
  },
  initialLocation: '/products',
  navigatorKey: rootNavigator,
  //observers: [CustomObserver()],
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

class CustomObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (route.settings.arguments is GoRouterState) {
      final state = route.settings.arguments as GoRouterState;
      print('Pushed:  ${state.fullPath} ${state.pathParameters}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    print('Popped: ${route.settings.name} -> ${previousRoute?.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('Popped: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }
}

class CustomPage extends CustomTransitionPage {
  CustomPage({required super.child, required GoRouterState state})
      : super(
          key: state.pageKey,
          arguments: state,
          transitionDuration: Duration(milliseconds: 300),
          reverseTransitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
                opacity:
                    CurveTween(curve: Curves.easeInOutCirc).animate(animation),
                child: child);
          },
        );
}
