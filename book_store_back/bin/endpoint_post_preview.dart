import 'dart:typed_data';

import 'package:shelf/shelf.dart' as shelf;
import 'dart:io';
import 'dart:convert';
import 'auth_provider.dart';
import 'server.dart';
import 'book_repository.dart';

Future<shelf.Response> postPreview (shelf.Request request) async {
  final authResult = await authProvider.authRequest(request, ['ADMIN']);
  final headers = {
    HttpHeaders.contentTypeHeader: ContentType.json.mimeType
  };
  addCorsPolicyHeaders(headers);

  if (authResult.result == AuthResult.noCredentials) {
    return shelf.Response(HttpStatus.unauthorized, headers: headers);
  }

  if (authResult.result == AuthResult.badCredentials || authResult.result == AuthResult.accessDenied) {
    return shelf.Response(HttpStatus.forbidden, headers: headers);
  }

  print('[${request.method}] [${request.requestedUri}] @${authResult.user?.username}');

  final title = request.url.queryParameters['title'];
  List<int> buffer = [];
  try {
    request.read().listen((data) {
      buffer.addAll(data);
    });

    await bookRepository.saveImgToDisk(title!, buffer);
  } catch (e) {
    print('Error parsing book data: $e');
    return shelf.Response(HttpStatus.badRequest, body: 'Invalid book data', headers: headers);
  }

  return shelf.Response(HttpStatus.ok, headers: headers);
}