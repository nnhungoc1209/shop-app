import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  const CartItem({Key? key, required this.id, required this.price, required this.quantity, required this.title, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: const Icon(
          Icons.delete,
          size: 40.0,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        margin: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 5.0,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove'),
            content: const Text(
              'Are you sure you want to remove this item?'
            ),
            actions: [
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                }
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                }
              )
            ],
          )
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 5.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  child: Text(
                    '\$$price',
                    style: const TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
            title: (Text(title)),
            subtitle: Text('Total: \$${price * quantity}'),
            trailing: Text('x $quantity'),
          ),
        ),
      ),
    );
  }
}
