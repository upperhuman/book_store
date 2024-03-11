import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;

import 'auth_provider.dart';
import 'server.dart';
import 'user_service.dart';



Future<shelf.Response> getUser(shelf.Request request) async {
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

  return shelf.Response.ok(authResult.user!.toDto().toJsonString(),
      headers: headers);
}
