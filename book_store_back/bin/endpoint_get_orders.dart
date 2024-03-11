import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;

import 'auth_provider.dart';
import 'server.dart';


Future<shelf.Response> getOrders(shelf.Request request) async {
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

  final orders = await orderService.getOrdersForUser(authResult.user!);

  List<dynamic> orderList = [];
  for (var order in orders) {
    orderList.add(order.toMap());
  }

  final body = jsonEncode(orderList);


  return shelf.Response(HttpStatus.ok,
      body: body,
      headers: headers
  );
}