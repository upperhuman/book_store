import 'dart:convert';

class User {
  static final User anonymous = User("", []);
  final String username;
  final List<String> roles;

  User(this.username, this.roles);

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool isAnonymous(){
    return this == User.anonymous;
  }

  bool isAuthorized() {
    return !isAnonymous();
  }

  bool isAdmin(){
    return hasRole("ADMIN");
  }
  bool isUser(){
    return hasRole("USER");
  }

  UserDto toDto() {
    return UserDto.fromUser(this);
  }

  User.fromDto(UserDto dto)
    : username = dto.username,
      roles = dto.roles;


  User.fromMap(Map<String, dynamic> map)
      : username = map['username'],
        roles = List<String>.from(map['roles']);

  User.fromJsonString(String jsonString)
      : this.fromMap(jsonDecode(jsonString));

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