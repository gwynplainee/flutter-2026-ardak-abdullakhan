import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear cart',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear cart?'),
                  content: const Text('All books will be removed.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              // the widget may have been removed while the dialog was open
              if (ok == true && context.mounted) {
                context.read<Cart>().clear();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) => ListView(
                children: [
                  for (final b in cart.items)
                    ListTile(
                      title: Text(b.title),
                      subtitle: Text('×${cart.qtyOf(b)} · ${b.price} ₸'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => cart.increment(b),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => cart.remove(b),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Consumer<Cart>(
            // built ONCE, handed to the builder as `child`
            child: const Row(
              children: [
                Icon(Icons.payments),
                SizedBox(width: 8),
                Text('Total'),
              ],
            ),
            builder: (context, cart, child) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [child!, const Spacer(), Text('${cart.total} ₸')],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
