import 'dart:ui';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'home.dart';
import '../models/models.dart';
import 'screens/screens.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const Yummy());
}

/// Allows the ability to scroll by dragging with touch, mouse, and trackpad.
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad
      };
}

class Yummy extends StatefulWidget {
  const Yummy({super.key});

  @override
  State<Yummy> createState() => _YummyState();
}

class _YummyState extends State<Yummy> {
  ThemeMode themeMode = ThemeMode.light;
  ColorSelection colorSelected = ColorSelection.pink;

  /// Authentication to manage user login session
  // ignore: unused_field
  final YummyAuth _auth = YummyAuth();

  /// Manage user's shopping cart for the items they order.
  final CartManager _cartManager = CartManager();

  /// Manage user's orders submitted
  final OrderManager _orderManager = OrderManager();

  // Initialize GoRouter
  late final _router = GoRouter(
// 2 Sets the initial route that the app will navigate to.
    initialLocation: '/login',
//  App Redirect
    redirect: _appRedirect,
// 3 routes contains a list of possible routes for the application.
    routes: [
// Login Route
      GoRoute(
// 1 The route is set to /login. When the URL or path matches /login go to the login route.
        path: '/login',
// 2 The builder() function creates the widget to display when the user hits a route.
        builder: (context, state) =>
// 3  The function returns a Login widget.
            LoginPage(
// 4 The Login widget takes a callback named onLogIn which returns the user credentials.
                onLogIn: (Credentials credentials) async {
// 5  Use the credentials to log in.
          _auth
              .signIn(credentials.username, credentials.password)
// 6 If the login is successful, navigate to the path /0, which is the first tab.
              .then((_) => context.go('/${YummyTab.home.value}'));
        }),
      ),
// Home Route
// 1 The route is set to /. When the URL or path matches / go to the home route. :tab is a path parameter used to switch between different tabs.
      GoRoute(
          path: '/:tab',
          builder: (context, state) {
            // 2 The builder function returns a Home widget.
            return Home(
                // 3  Pass auth for handling authentication
                auth: _auth,
                //4 Use cartManager to manage the items that the user added to the cart.
                cartManager: _cartManager,
                // 5 Use ordersManager to manage all the orders submitted.
                ordersManager: _orderManager,
                // 6 Set a callback to handle user changes from light to dark mode.
                changeTheme: changeThemeMode,
                //7 Set a callback to handle user app color theme changes.
                changeColor: changeColor,
                //8  Pass the currently selected color theme.
                colorSelected: colorSelected,
                //9 Set the current tab, default to 0 if the path parameter is absent or not an integer.
                tab: int.tryParse(state.pathParameters['tab'] ?? '') ?? 0);
          },
// 10
          routes: [
// Restaurant Route
            GoRoute(
// 1 The route is defined with the path restaurant/:id. The :id part is a path parameter, which allows for dynamic routing based on the restaurant’s ID.
                path: 'restaurant/:id',
                builder: (context, state) {
// 2 Within the builder() function, you extract the id from pathParameters.
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
// 3  Get the restaurant based on the `id``.
                  final restaurant = restaurants[id];
// 4 Return the RestaurantPage widget with the specific restaurant, cart and order manager.
                  return RestaurantPage(
                    restaurant: restaurant,
                    cartManager: _cartManager,
                    ordersManager: _orderManager,
                  );
                }),
          ]),
    ],

// Error Handler
    errorPageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          body: Center(
            child: Text(
              state.error.toString(),
            ),
          ),
        ),
      );
    },
  );

  // Redirect Handler
  // 1 _appRedirect() is an asynchronous function that returns a future, optional string. It takes in a build context and the go router state.
  Future<String?> _appRedirect(
      BuildContext context, GoRouterState state) async {
// 2  Get the login status.
    final loggedIn = await _auth.loggedIn;
// 3 Check if the user is currently on the login page.
    final isOnLoginPage = state.matchedLocation == '/login';
// 4  If the user is not logged in yet, redirect to the login page.
// Go to /login if the user is not signed in
    if (!loggedIn) {
      return '/login';
    }
// 5  If the user is logged in and is on the login page, redirect to the home page.
// Go to root if the user is already signed in
    else if (loggedIn && isOnLoginPage) {
      return '/${YummyTab.home.value}';
    }
    // 6 Don’t redirect if no condition is met.
// no redirect
    return null;
  }

  void changeThemeMode(bool useLightMode) {
    setState(() {
      themeMode = useLightMode
          ? ThemeMode.light //
          : ThemeMode.dark;
    });
  }

  void changeColor(int value) {
    setState(() {
      colorSelected = ColorSelection.values[value];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Router
    // 1 MaterialApp.router. This constructor is used for apps with a navigator that uses a declarative routing approach.
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
// 2  routeConfig reads _router to know about navigation properties.
      routerConfig: _router,
// Custom Scroll Behavior
      title: 'Yummy',
      scrollBehavior: CustomScrollBehavior(),
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}
