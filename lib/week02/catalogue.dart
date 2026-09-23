import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'Unknown';

  void open() {
    openedAt = DateTime.now();
  }

  String buildReport() {
    return _cachedReport ??= 'Report: ${items.length} items in the catalogue.';
  }

  Iterable<String> get allTitles => items.map((item) => item.title);

  Iterable<Book> get modernBooks =>
      items.whereType<Book>().where((book) => book.year > 2010);

  /// We use `fold` instead of `reduce` for two reasons:
  /// 1. `reduce` requires the accumulator to be the exact same type as the collection
  ///    elements (Book), but we need to accumulate an `int` (the sum of pages).
  /// 2. `reduce` throws a StateError on empty collections, whereas `fold` safely
  ///    returns the initial value.
  double get averagePageCount =>
      items.whereType<Book>().fold<int>(0, (sum, book) => sum + book.pages) /
      (items.whereType<Book>().isEmpty ? 1 : items.whereType<Book>().length);

  Map<String, int> get booksPerAuthor =>
      items.whereType<Book>().fold<Map<String, int>>(
        <String, int>{},
        (map, book) => map
          ..update(book.author.name, (count) => count + 1, ifAbsent: () => 1),
      );

  Set<String> get distinctAuthors =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get presentGenres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
    'CATALOGUE',

    for (final book in items.whereType<Book>()) '${book.title} (${book.year})',

    ...distinctAuthors,

    if (items.whereType<Book>().any((book) => book.pages == 0))
      '(incomplete data)',
  ];
}
