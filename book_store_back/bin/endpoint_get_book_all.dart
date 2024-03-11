import 'package:shelf/shelf.dart' as shelf;
import 'dart:io';
import 'dart:convert';
import 'server.dart';

shelf.Response getBookAll(shelf.Request request) {
  List<Map<String, dynamic>> listBook = [];
  for(var entry in bookRepository.books.entries){
    listBook.add(entry.value.toMap());
  }
  final body = jsonEncode(listBook);
  final headers = {
    HttpHeaders.contentTypeHeader: ContentType.json.mimeType
  };
  addCorsPolicyHeaders(headers);

  return shelf.Response(HttpStatus.ok,
      body: body,
      headers: headers
  );
}