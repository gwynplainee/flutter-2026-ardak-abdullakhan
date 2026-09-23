import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';
import 'data.dart';

void main() {
  final library = Library();
  library.open();

  final parsedBooks = rawBooks.map((json) => Book.fromJson(json)).toList();
  for (final book in parsedBooks) {
    library.add(book);
  }

  print('--- QUERIES ---');
  print('All Titles: ${library.allTitles.join(', ')}');
  print('Modern Books: ${library.modernBooks.map((b) => b.title).join(', ')}');
  print('Average Page Count: ${library.averagePageCount.toStringAsFixed(1)}');
  print('Books Per Author: ${library.booksPerAuthor}');
  print('Distinct Authors: ${library.distinctAuthors}');
  print(
    'Present Genres: ${library.presentGenres.map((g) => g.label).join(', ')}',
  );
  print('Country of Refactoring: ${library.countryOf('Refactoring')}');
  print('Country of Missing Book: ${library.countryOf('Not Real')}');

  print('\n--- DISPLAY LIST LITERAL ---');
  library.displayList.forEach(print);

  print('\n--- RECORD STATS ---');
  final stats = statsOf(parsedBooks);
  print(
    'Stats Record: Count = ${stats.count}, Avg Pages = ${stats.avgPages.toStringAsFixed(1)}',
  );

  print('\n--- SHELF STATES (SEALED) ---');
  final stateEmpty = Empty();
  final stateReady = Ready(parsedBooks);
  final stateBroken = Broken('Termites ate the wooden legs.');

  print('Empty state:  ${describe(stateEmpty)}');
  print('Ready state:  ${describe(stateReady)}');
  print('Broken state: ${describe(stateBroken)}');
}
