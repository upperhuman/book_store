import 'package:shelf/shelf.dart' as shelf;
import 'dart:io';
import 'dart:convert';
import 'server.dart';

shelf.Response getBook(shelf.Request request) {
  final title = request.url.queryParameters['title'];

  if (title == null) {
    return shelf.Response(HttpStatus.badRequest, body: 'Title is required');
  }

  final book = bookRepository.findByTitle(title);

  if (book == null) {
    return shelf.Response.notFound('Book not found');
  }

  final body = jsonEncode(book.toMap());
  final headers = {
    HttpHeaders.contentTypeHeader: ContentType.json.mimeType
  };
  addCorsPolicyHeaders(headers);

  return shelf.Response(HttpStatus.ok,
      body: body,
      headers: headers
  );
}