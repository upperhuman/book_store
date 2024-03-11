import 'package:book_store_front/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:book_store_front/home_page.dart';

import 'book_repository.dart';

final themeNotifier = ValueNotifier(ThemeMode.system);

final currentUserNotifier = ValueNotifier(User.anonymous);
String? credentials;

List<BookOrderEntity> orderEntities = [];

const localeEnUs = Locale('en', 'US');
const localeUkUa = Locale('uk', 'UA');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: const [
          localeEnUs,
          localeUkUa
        ],
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, value, child) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          title: 'Book Store',
          themeMode: value,
          theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Color.fromRGBO(131, 187, 206, 1.0)),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.95),
              actionTextColor: Colors.black,
                contentTextStyle: TextStyle(
                    color: Colors.black
                ),
            )
          ),
          darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Color.fromRGBO(24, 50, 61, 1.0)),
              snackBarTheme: const SnackBarThemeData(
                  backgroundColor: Colors.black45,
                actionTextColor: Colors.white,
                contentTextStyle: TextStyle(
                  color: Colors.white
                )
              )
          ),

          home: const BookStoreHomePage(),
        );
      }
    );
  }
}


class BookOrderEntity {

  final Book book;
  int count;
  bool cardValue = false;
  final TextEditingController countController = TextEditingController(text: '1');

  BookOrderEntity(this.book, this.count);

  void incrementCount() {
    count++;
    countController.text = count.toString();
  }

  bool orderExist(){
    return cardValue;
  }

  void decrementCount() {
    count--;

    if (count <= 0) {
      count = 1;
    }

    countController.text = count.toString();
  }

  double getCostTotal() {
    return book.price * count;
  }

}