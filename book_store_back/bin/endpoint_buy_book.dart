import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;

import 'auth_provider.dart';
import 'order_dto.dart';
import 'server.dart';



Future<shelf.Response> buyBook(shelf.Request request) async {
  final authResult = await authProvider.authRequest(request);

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

  try {
    final body = await request.readAsString();

    Map<String, dynamic> json = jsonDecode(body);

    try {
      await orderService.submitOrder(authResult.user!, OrderDto.fromMap(json));
    } catch (e) {
      print('Error submitting order: $e');
      return shelf.Response(HttpStatus.internalServerError, body: 'Error submitting order: ${e.toString()}', headers: headers);
    }
  } catch (e) {
    print('Error parsing book data: $e');
    return shelf.Response(HttpStatus.badRequest, body: 'Invalid book data', headers: headers);
  }



  return shelf.Response(HttpStatus.ok, headers: headers);
}