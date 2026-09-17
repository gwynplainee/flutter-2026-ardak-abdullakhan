class Author{
  final String name;
  final String? country;

  Author({
    required this.name,
    this.country
  });

  @override
  String toString() => 'Author(name: $name, country: $country)';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  final String label;
  const Genre(this.label);

  static Genre fromString(String? raw) {
    if (raw == null) return Genre.unknown;

    switch (raw.trim().toLowerCase()) {
      case 'craft':
        return Genre.craft;
      case 'theory':
        return Genre.theory;
      default:
        return Genre.unknown;
    }
  }
}

/// Level 2
abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({
    required this.title,
    required this.year,
  });

  String describe();

  bool get isOld => year < 2000;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Ready to borrow: "$title"';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  bool get isLong => pages > 400;

  @override
  String describe() => 'Book: $title by ${author.name}';

  factory Book.fromJson(Map<String, dynamic> json) {
    final authorName = json['author'] as String? ?? 'Unknown Author';
    final authorCountry = json['country'] as String?;

    final author = Author(
      name: authorName,
      country: authorCountry,
    );

    return Book(
      title: json['title'] as String? ?? 'Untitled',
      year: json['year'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      author: author,
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Book(title: $title, year: $year, pages: $pages, '
        'author: $author, genre: ${genre.label}, description: $description)';
  }
}

class Magazine extends LibraryItem {
  final String issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() => 'Magazine: $title (Issue: $issue)';
}

class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  const Ghost({
    required this.title,
    required this.year,
  });

  @override
  String describe() => 'A ghost item named "$title"';

  @override
  bool get isOld => true;
}
