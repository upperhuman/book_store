import 'package:shelf/shelf.dart' as shelf;
import 'dart:io';
import 'server.dart';

Future<shelf.Response> deleteBook(shelf.Request request) async {
  final title = request.url.queryParameters['title'];

  final headers = {
    HttpHeaders.contentTypeHeader: ContentType.json.mimeType
  };
  addCorsPolicyHeaders(headers);

  if (title == null) {
    return shelf.Response(HttpStatus.badRequest, body: 'Title is required', headers: headers);
  }
  if (!bookRepository.existByTitle(title)){
    return shelf.Response(HttpStatus.notFound, body: 'Book not found', headers: headers);
  }
  try{
    await bookRepository.deleteBookByTitle(title);
  }catch(e){
    print('Error deleted book: $e');
    return shelf.Response(HttpStatus.badRequest, body: 'Error deleted book: $e', headers: headers);
  }


  return shelf.Response(HttpStatus.ok, headers: headers);
}