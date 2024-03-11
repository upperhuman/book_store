import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class BookRepository {

  static const rootPath = 'books';

  final Map<String, Book> books = {};

  BookRepository();


  void addBook(Book book) {
    books[book.title] = book;
  }

  Book? findByTitle(String title) {
    return books[title];
  }


  Future<void> genDir() async {
    Directory bookDir = Directory(rootPath);

    if (! await bookDir.exists()) {
      print('Creating directory ${bookDir.path}');

      try {
        await bookDir.create();
      } catch (e) {
        print('Error creating directory: $e');
      }
    }
  }

  bool existByTitle(String title){
    return books.containsKey(title);
  }

  Future<void> deleteBookByTitle(String title) async {
    Book? book = books[title];

    if (book == null){
      return;
    }
    books.remove(book.title);
    final path = '$rootPath/${book.title}.json';
    final file = File(path);
    await file.delete();
  }

  Future<List<int>?> getBookImgByTitle(String title) async {
    Book? book = books[title];

    final path = '$rootPath/preview/${book!.title}.png';
    final file = File(path);
    if(file.existsSync()){
      final img = await file.readAsBytes();
      return img;
    }
    return null;
  }

  Future<void> saveImgToDisk(String title, List<int> img) async {
    Directory bookDir = Directory(rootPath);

    if (! await bookDir.exists()) {
      await genDir();
    }

    print('Saving img to disk');

    final path = '${bookDir.path}/preview/$title.png';
    final file = File(path);
    await file.writeAsBytes(img);
  }


  Future<void> saveToDisk() async {
    Directory bookDir = Directory(rootPath);

    if (! await bookDir.exists()) {
      await genDir();
    }

    print('Saving books to disk');

    for (var book in books.entries) {
      final path = '${bookDir.path}/${book.key}.json';
      final file = File(path);

      final jsonEncoder = JsonEncoder.withIndent('  ');

      await file.writeAsString(jsonEncoder.convert(book.value.toMap()));
    }

  }

  Future<void> loadFromDisk() async {
    Directory bookDir = Directory(rootPath);

    if (! await bookDir.exists()) {
      print('No books found on disk');
      await genDir();
      return;
    }

    print('Loading books from disk');

    final files = await bookDir.list().toList();

    for (var file in files) {
      final fileStat = await file.stat();

      if (fileStat.type != FileSystemEntityType.file) {
        continue;
      }

      File f = file as File;

      final contents = await f.readAsString();

      final bookMap = jsonDecode(contents);

      final book = Book.fromMap(bookMap);
      books[book.title] = book;

      print('Loaded book: ${book.title}');
    }
  }

}

class Book {
  final String title;
  final String description;
  final String author;
  final double price;
  final String preview;

  Book(this.title, this.description, this.author, this.preview, this.price);

  Book.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        description = map['description'],
        author = map['author'],
        price = (map['price'] as num).toDouble(),
        preview = map['preview'];

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
