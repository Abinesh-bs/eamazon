import 'package:e_amazon/pages/auth/register.dart';
import 'package:e_amazon/pages/home.dart';
import 'package:e_amazon/pages/products/confirm_order.dart';
import 'package:e_amazon/pages/products/product.dart';
import 'package:e_amazon/pages/products/product_details.dart';
import 'package:e_amazon/pages/wishlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/auth/edit_profile.dart';
import '../pages/auth/login.dart';
import '../pages/splash.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String register = '/register';
  static const String login = '/login';
  static const String products = '/products';
  static const String productDetail = '/productDetail';
  static const String wishlist = '/wishlist';
  static const String confirmOrder = '/confirmOrder';
  static const String editProfile = '/editProfile';

  static Route<dynamic> generateRoutes(RouteSettings routeSettings) {
    Map args = (routeSettings.arguments ?? {}) as Map;

    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (context) => Login());
      case splash:
        return MaterialPageRoute(builder: (context) => Splash());
      case home:
        return MaterialPageRoute(builder: (context) => Home());
      case register:
        return MaterialPageRoute(builder: (context) => Register());
      case products:
        return MaterialPageRoute(builder: (context) => Product());
      case wishlist:
        return MaterialPageRoute(builder: (context) => Wishlists());
      case editProfile:
        return MaterialPageRoute(builder: (context) => EditProfile());
      case confirmOrder:
        String? productId = args['productId'];
        bool isFromCart = args['isFromCart'];
        return MaterialPageRoute(
          builder: (context) =>
              ConfirmOrder(productId: productId, isFromCart: isFromCart),
        );

      case productDetail:
        String id = args['id'];
        return MaterialPageRoute(
          builder: (context) => ProductDetails(productId: id),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) =>
              Scaffold(
                body: Center(
                  child: Text('No route defined for ${routeSettings.name}'),
                ),
              ),
        );
    }
  }
}
