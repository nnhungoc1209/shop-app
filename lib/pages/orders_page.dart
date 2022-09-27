import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersPage extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Future? _ordersFuture;

  Future _obtainOrdersFuture() {
    return  Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  //var _isLoading = false;

  @override
  void initState() {
    // Future.delayed(Duration.zero).then((_) async {
    //   setState(() {
    //     _isLoading = true;
    //   });
    //
    //   await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    //
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });

    _ordersFuture = _obtainOrdersFuture();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      // body: _isLoading
      // ? const Center(child: CircularProgressIndicator())
      // : ListView.builder(
      //   itemCount: orderData.orders.length,
      //   itemBuilder: (context, index) => OrderItem(order: orderData.orders[index],)
      // ),

      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              //Handling error...
              return const Center(child: Text('Error'));
            } else {
              return Consumer<Orders>(
                builder: (context, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, index) => OrderItem(order: orderData.orders[index],)
                ),
              );
            }
          }
        }
      )
    );
  }
}
