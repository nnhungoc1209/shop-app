import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/edit_product_page.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductPage extends StatelessWidget {
  static const routeName = '/use-product';

  const UserProductPage({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false).fetchAnfSetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, EditProductPage.routeName);
            },
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
          ? const Center(
            child: CircularProgressIndicator(),
          )
          : RefreshIndicator(
            onRefresh: () => _refreshProducts(context),
            child: Consumer<ProductsProvider>(
              builder: (context, productsData, _) => Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: productsData.items.length,
                  itemBuilder: (_, index) => Column(
                    children: [
                      UserProductItem(
                        id: productsData.items[index].id,
                        title: productsData.items[index].title,
                        imageUrl: productsData.items[index].imageUrl,
                      ),
                      const Divider(),
                    ],
                  )
                ),
              ),
            ),
        ),
      ),
    );
  }
}
