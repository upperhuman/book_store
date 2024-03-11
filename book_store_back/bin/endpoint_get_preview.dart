import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;

import 'server.dart';


Future<shelf.Response> getPreview(shelf.Request request) async {
  final title = request.url.queryParameters['title'];

  Map<String, String> headers = {};
  addCorsPolicyHeaders(headers);

  if (title == null) {
    headers[HttpHeaders.contentTypeHeader] = ContentType.text.mimeType;
    return shelf.Response(HttpStatus.badRequest, body: 'Title is required', headers: headers);
  }

  if (!bookRepository.existByTitle(title)) {
    headers[HttpHeaders.contentTypeHeader] = ContentType.text.mimeType;
    return shelf.Response.notFound('Title not found', headers: headers);
  }

  final body = await bookRepository.getBookImgByTitle(title);
  if(body == null){
    headers[HttpHeaders.contentTypeHeader] = ContentType.text.mimeType;
    return shelf.Response(HttpStatus.notFound, body: 'Preview not found', headers: headers);
  }
  headers[HttpHeaders.contentTypeHeader] = "image/png";
  return shelf.Response(HttpStatus.ok,
      body: body,
      headers: headers
  );
}