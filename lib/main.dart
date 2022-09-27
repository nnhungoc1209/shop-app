import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/pages/auth_page.dart';
import 'package:shop_app/pages/cart_page.dart';
import 'package:shop_app/pages/orders_page.dart';

import 'package:shop_app/pages/product_detail_page.dart';
import 'package:shop_app/pages/product_overview_page.dart';
import 'package:shop_app/pages/splash_screen_page.dart';
import 'package:shop_app/pages/user_product_page.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/edit_product_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          update: (context, auth, previousProducts) => ProductsProvider(
            auth.token ?? '',
            auth.userId ?? '',
            previousProducts == null ? [] : previousProducts.items,
          ),
          create: (context) => ProductsProvider('', '', []),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, auth, previousOrders) => Orders(
            auth.token ?? '',
            auth.userId ?? '',
            previousOrders == null ? [] : previousOrders.orders,
          ),
          create: (context) => Orders('', '', []),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primaryColor: Colors.teal,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(secondary: Colors.deepOrange),
            fontFamily: 'Lato',
          ),
          //home: const ProductsOverviewPage(),
          home: auth.isAuth
            ? const ProductsOverviewPage()
            : FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (context, authResultSnapshot) =>
              authResultSnapshot.connectionState == ConnectionState.waiting
                ? SplashScreenPage()
                : AuthPage()
          ),
          routes: {
            ProductDetailPage.routeName: (context) => const ProductDetailPage(),
            CartPage.routeName: (context) => const CartPage(),
            OrdersPage.routeName: (context) => const OrdersPage(),
            UserProductPage.routeName: (context) => const UserProductPage(),
            EditProductPage.routeName: (context) => const EditProductPage(),
          },
        ),
      )
    );
  }
}