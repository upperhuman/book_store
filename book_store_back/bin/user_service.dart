
import 'dart:convert';
import 'dart:io';

class UserService {

  static const rootPath = 'users';

  final Map<String, User> users = {};

  UserService();

  void addUser(User user) {
    users[user.username] = user;
  }


  User? findByUsername(String username) {
    return users[username];
  }


  Future<void> loadAll() async {
    final dir = Directory(rootPath);
    if (! await dir.exists()) {
      print('No users found');
      await dir.create();
      return;
    }

    final files = dir.listSync();
    for (var file in files) {
      if (file is File) {
        final jsonString = await file.readAsString();
        final user = User.fromJsonString(jsonString);
        print('Loaded user: ${user.username}');
        addUser(user);
      }
    }

  }

  void saveAll() async {
    final dir = Directory(rootPath);
    if (! await dir.exists()) {
      await dir.create();
    }

    for (var user in users.values) {
      final file = File('$rootPath/${user.username}.json');
      await file.writeAsString(user.toJsonString());
    }
  }

}



class User {
  final String username;
  final String password;
  final List<String> roles;

  User(this.username, this.password, this.roles);

  bool hasRole(String role) {
    return roles.contains(role);
  }

  UserDto toDto() {
    return UserDto.fromUser(this);
  }

  User.fromMap(Map<String, dynamic> map)
      : username = map['username'],
        password = map['password'],
        roles = List<String>.from(map['roles']);

  User.fromJsonString(String jsonString)
      : this.fromMap(jsonDecode(jsonString));

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'roles': roles
    };
  }

  String toJsonString([JsonEncoder? encoder]) {
    return (encoder ?? JsonEncoder.withIndent('  ')).convert(toMap());
  }
}

class UserDto {
  final String username;
  final List<String> roles;

  UserDto(this.username, this.roles);

  UserDto.fromUser(User user)
      : username = user.username,
        roles = user.roles;

  UserDto.fromMap(Map<String, dynamic> map)
      : username = map['username'],
        roles = List<String>.from(map['roles']);

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'roles': roles
    };
  }

  String toJsonString([JsonEncoder? encoder]) {
    return (encoder ?? JsonEncoder.withIndent('  ')).convert(toMap());
  }
}