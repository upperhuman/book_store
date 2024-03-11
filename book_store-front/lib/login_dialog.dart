import 'dart:io';

import 'package:book_store_front/main.dart';
import 'package:book_store_front/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String error = "";

  void processAuth() async{
    if(usernameController.text.isEmpty){
      setState(() {
        error = "login.dialog.username.can.not.be.empty".tr();
      });
      return;
    }
    if (passwordController.text.isEmpty){
      setState(() {
        error = "login.dialog.password.can.not.be.empty".tr();
      });
      return;
    }
    final username = usernameController.text;
    final password = passwordController.text;
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    Map<String, String> headers= {
      HttpHeaders.authorizationHeader: basicAuth,
    };
    var response = await http.get(Uri.parse('http://localhost:8081/user'),
        headers: headers);
    if (!mounted) return;
    if(response.statusCode == HttpStatus.forbidden){
      setState(() {
        error = "login.dialog.not.correct.password.or.username".tr();
      });
    }
    if (response.statusCode == HttpStatus.ok){
      String body = response.body;
      Map<String, dynamic> map = jsonDecode(body);
      UserDto userDto = UserDto.fromMap(map);
      User user = User.fromDto(userDto);
      currentUserNotifier.value = user;
      credentials = basicAuth;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const ContinuousRectangleBorder(),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(
            maxWidth: 400,
        ),
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              children: [
                Text(
                  'login.dialog.page.login'.tr(),
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: "login.dialog.username".tr()),
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: [
                    AutofillHints.username
                  ],
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'login.dialog.password'.tr()),
                  onEditingComplete: processAuth,
                  autofillHints: [
                    AutofillHints.password
                  ],
                ),
                const SizedBox(height: 20,),
                error.isNotEmpty
                    ? Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 16),)
                    : const SizedBox.shrink(),
                error.isNotEmpty
                  ? const SizedBox(height: 20,)
                  : const SizedBox.shrink(),
                TextButton(
                    onPressed: processAuth,
                    child: Text('login.dialog.login'.tr())
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
