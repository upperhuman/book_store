
import 'dart:convert';
import 'dart:typed_data';

class BookRepository {
  static final empty = BookRepository([]);

  final List<Book> books;

  BookRepository(this.books);
}

class Book {
  final String title;
  final String description;
  final String author;
  final String preview;
  final double price;
  late Uint8List previewBytes;

  Book(this.title, this.description, this.author, this.preview, this.price, this.previewBytes);

  Book.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        description = map['description'],
        author = map['author'],
        preview = map['preview'],
        price = map['price']
  {
    if (preview.isEmpty){
      previewBytes = Uint8List(0);
    }
    else {
      previewBytes = base64Decode(map["preview"]);
    }
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'preview': preview,
      'price': price
    };
  }
}
