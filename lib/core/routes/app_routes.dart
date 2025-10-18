import 'package:flutter/material.dart';
import 'package:product_sale_app/core/view/product_detail_page.dart';
import 'package:product_sale_app/core/model/product_model.dart';
import 'package:product_sale_app/core/view/login_screen.dart';
import 'package:product_sale_app/core/view/product_list_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetail = '/productDetail';
  static const String pdfList = '/pdfList';

  static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case login:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case products:
      return MaterialPageRoute(
          builder: (context) => const ProductListingScreen());
    case productDetail:
      final productId = settings.arguments as String?; // Cast to String
      return MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productId: productId ?? "",
        ),
      );
    default:
      return MaterialPageRoute(
          builder: (context) => const LoginScreen()); // Default route
  }
}

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => const LoginScreen(),
    products: (BuildContext context) => const ProductListingScreen(),
    // You don't need to directly map productDetail here anymore
  };
}
