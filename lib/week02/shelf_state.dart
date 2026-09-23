import 'models.dart';

sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;
  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
  Empty() => 'The shelf is completely empty.',
  Ready(books: final b) => 'The shelf is ready and holds ${b.length} books.',
  Broken(message: final msg) => 'The shelf is broken: $msg',
};

({int count, double avgPages}) statsOf(List<Book> books) {
  final count = books.length;
  if (count == 0) {
    return (count: 0, avgPages: 0.0);
  }

  final totalPages = books.fold<int>(0, (sum, book) => sum + book.pages);
  return (count: count, avgPages: totalPages / count);
}
