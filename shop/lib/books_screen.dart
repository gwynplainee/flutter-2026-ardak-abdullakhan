import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(title: const Text('Books'), actions: const [CartBadge()]),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (_, i) => BookRow(book: books[i]),
      ),
    );
  }
}

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    debugPrint('row ${book.title}');
    // watch: the Added/Add decision depends on the cart
    final inCart = context.watch<Cart>().items.contains(book);
    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              // read: a callback, not a subscription
              onPressed: () {
                final ok = context.read<Cart>().add(book);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}
