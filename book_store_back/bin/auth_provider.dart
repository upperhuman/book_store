
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart' as shelf;


import 'user_service.dart';

class AuthProvider {

  final UserService userService;

  AuthProvider(this.userService);



  Future<AuthResultContainer> authRequest(shelf.Request request, [List<String> requiredRoles = const []]) async {
    String? authHeader = request.headers[HttpHeaders.authorizationHeader];
    if (authHeader == null || authHeader.isEmpty || authHeader.trim().isEmpty) {
      return AuthResultContainer(AuthResult.noCredentials, null);
    }

    //basic authorization: Basic base64(username:password)
    String rawCredentials = authHeader.split(' ')[1];

    if (rawCredentials.isEmpty) {
      return AuthResultContainer(AuthResult.noCredentials, null);
    }

    Uint8List decoded = base64.decode(rawCredentials);
    String credentials = String.fromCharCodes(decoded);

    List<String> parts = credentials.split(':');

    print('Attempt to login with username: ${parts[0]} and password: ${parts[1]}');

    String username = parts[0];
    String password = parts[1];

    User? user = userService.findByUsername(username);

    if (user == null) {
      return AuthResultContainer(AuthResult.badCredentials, null);
    }

    if (user.password != password) {
      return AuthResultContainer(AuthResult.badCredentials, null);
    }

    if (requiredRoles.isNotEmpty) {
      for (var role in requiredRoles) {
        if (!user.hasRole(role)) {
          return AuthResultContainer(AuthResult.accessDenied, null);
        }
      }
    }

    return AuthResultContainer(AuthResult.success, user);
  }

}



class AuthResultContainer {

  final AuthResult result;
  final User? user;

  AuthResultContainer(this.result, this.user);

  bool isSuccess() {
    return result == AuthResult.success;
  }

}


enum AuthResult {
  success, //everything is fine
  noCredentials, //no credentials were provided
  badCredentials, //credentials were provided but they are wrong (user not found, password wrong)
  accessDenied, //credentials are correct but user is not allowed to access the resource (required role not present)
  ;
}