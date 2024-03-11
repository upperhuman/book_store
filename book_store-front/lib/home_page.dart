import 'package:book_store_front/order_list_page.dart';
import 'package:book_store_front/shoping_cart_dialog.dart';
import 'package:book_store_front/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:book_store_front/book_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_dialog.dart';
import 'package:book_store_front/edit_book_page.dart';

import 'main.dart';

void toEditBookPage(BuildContext context, void Function()? loadBooksCallback) {
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditBookPage(null, loadBooksCallback)));
}

void toOrderList(BuildContext context){
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const OrderListPage())
  );
}

void showShoppingCartDialog(BuildContext context, void Function(void Function()) setState) {
  showDialog(
      context: context,
      builder: (context) => ShoppingCartDialog(
              () => setState(() {}),
              (SnackBar snackBar){
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              })
  );
}

class BookStoreHomePage extends StatefulWidget {
  const BookStoreHomePage({super.key});

  @override
  State<BookStoreHomePage> createState() => _BookStoreHomePageState();
}

class _BookStoreHomePageState extends State<BookStoreHomePage> {
  final ValueNotifier<BookRepository> booksNotifier =
      ValueNotifier<BookRepository>(BookRepository.empty);

  BookRepository fetchedBooks = BookRepository.empty;

  bool loading = false;

  @override
  void initState() {
    loadBooks();
    super.initState();
  }


  void loadBooks() async {
    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    var response = await http.get(Uri.parse('http://localhost:8081/book/all'));

    List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));

    List<Book> books = [];

    for (var item in list) {
      Map<String, dynamic> map = item;
      books.add(Book.fromMap(map));
    }

    booksNotifier.value = BookRepository(books);
    fetchedBooks = BookRepository(books);
    setState(() {
      loading = false;
    });
  }

  void deleteBook(Book book) async {

    var response = await http
        .post(Uri.parse('http://localhost:8081/delete?title=${book.title}'));
    loadBooks();
  }

  bool orderExist(Book book){
    for(var e in orderEntities)
      if(e.book == book)
        return true;
    return false;
  }

  void addBookToCart(Book book) {
    for (var e in orderEntities) {
      if (e.book == book) {
        e.incrementCount();
        e.cardValue = true;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info),
                    const SizedBox(width: 10,),
                    RichText(
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: "increased.book.count".tr(),
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                )
                            ),
                            TextSpan(
                                text: book.title,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.cyan
                                      : Colors.purple,
                                )
                            ),
                            TextSpan(
                                text: "book.count".tr(),
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                )
                            ),
                            TextSpan(
                                text: e.count.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.cyan
                                      : Colors.purple,
                                )
                            ),
                          ]
                      ),
                    ),
                  ],
                )
            )
        );
        return;
      }
      e.cardValue = false;
    }


    orderEntities.add(BookOrderEntity(book, 1));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info),
              const SizedBox(width: 10,),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: "ntf.book_added_to_cart".tr(), //ntf.book_added_to_cart
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )
                    ),
                    TextSpan(
                      text: book.title,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.cyan
                          : Colors.purple,
                      )
                    )
                  ]
                ),
              ),
            ],
          )
      )
    );
  }

  Widget buildPopupMenu(BuildContext context, Book book) {
    return ValueListenableBuilder(
        valueListenable: currentUserNotifier,
        builder: (context, value, child) {
          return PopupMenuButton<String>(onSelected: (String item) {
            if (value.isAdmin() && item == "delete") {
              deleteBook(book);
            }
            if (value.isAdmin() && item == "edit") {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditBookPage(book, loadBooks)));
            }

            if (item == "add_to_cart") {
              addBookToCart(book);
            }
          }, itemBuilder: (BuildContext context) {
            List<PopupMenuEntry<String>> children = [];

            children.addAll([
              const PopupMenuItem<String>(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 10),
                    Text(
                      'Delete', //manage.remove_book
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: "edit",
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Edit'), // manage.edit_book
                  ],
                ),
              ),
            ]);

            //anonymous
            children.addAll([
              const PopupMenuItem<String>(
                value: "add_to_cart",
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Put in cart'),
                  ],
                ),
              ),
            ]);

            return children;
          }
          );
        });
  }

  Widget buildBookTile(BuildContext context, Book book) {
    //todo: implement show book button
    return Container(
      width: 230,
      height: 400,
      padding: const EdgeInsets.all(10),
      color: Colors.black12,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: book.preview.isEmpty
                    ? const Center(
                        child: Text(
                          "?",
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 210,
                        child: Image.memory(
                          book.previewBytes,
                          fit: BoxFit.fill,
                        ),
                      ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                book.title.length > 21
                    ? "${book.title.substring(0, 21)}..."
                    : book.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                book.author,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 10,),
              Text(
                '${book.price} ₴',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic
                ),
              ),
            ],
          ),

          ValueListenableBuilder(
            valueListenable: currentUserNotifier,
            builder: (context, value, child) {
              return Positioned(
                  right: 5,
                  bottom: 5,
                  child: Row(
                    children: [
                      IconButton(
                          color: orderExist(book)
                              ? Theme.of(context).brightness == Brightness.dark
                                ? Colors.cyan
                                : Colors.purple
                              : null,
                          onPressed: () => setState(() {
                            addBookToCart(book);
                          }
                          ),
                          icon: const Icon(Icons.shopping_cart)
                      ),
                      const SizedBox(height: 5,),

                      value.isAdmin()
                          ? Container(
                            child: buildPopupMenu(context, book)
                      )
                          : const SizedBox.shrink(),


                    ],
                  )
              );
          }),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('page.home.title'.tr()),
          actions: [
            ValueListenableBuilder(
              valueListenable: currentUserNotifier,
              builder: (context, value, child) {
                if (value.isAnonymous()) {
                  return TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const LoginDialog();
                          },
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.login),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('misc.auth.login.button'.tr())
                        ],
                      ));
                }
                return Row(
                  children: [
                    Text('misc.app_bar.auth.prefix'.tr()),
                    PopupMenuButton<String>(
                      child: Text(
                        value.username,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.cyan
                              : Colors.purple,
                        ),
                      ),
                      onSelected: (String item) {
                        if (value.isAdmin() && item == "add_book") {
                          toEditBookPage(context, loadBooks);
                        }

                        if (item == "logout") {
                          currentUserNotifier.value = User.anonymous;
                          credentials = null;
                        }

                        if (item == "orders_history"){
                          toOrderList(context);
                        }

                      },

                      itemBuilder: (BuildContext context) {
                        List<PopupMenuEntry<String>> children = [];

                        children.add(
                          PopupMenuItem<String>(
                            value: "orders_history",
                            child: Row(
                              children: [
                                const Icon(Icons.list),
                                const SizedBox(width: 10),
                                Text(
                                  'list.order'.tr(), //manage.add_book
                                ),
                              ],

                            ),
                          ),
                        );

                        if (value.isAdmin()) {
                          children.add(
                            const PopupMenuItem<String>(
                              value: "add_book",
                              child: Row(
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 10),
                                  Text(
                                    'Add New Book', //manage.add_book
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        children.add(
                          PopupMenuItem<String>(
                            value: "logout",
                            child: Row(
                              children: [
                                const Icon(Icons.logout_outlined),
                                const SizedBox(width: 10),
                                Text(
                                  'misc.app_bar.auth.logout'.tr(),
                                ),
                              ],
                            ),
                          ),
                        );

                        return children;
                      }
                    ),
                  ],
                );
              },
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
                onPressed: () => showShoppingCartDialog(context, setState),
                icon: const Icon(Icons.shopping_cart)
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              child: Text(
                context.locale == localeEnUs
                    ? 'EN'
                    : 'UA'
              ),
              onPressed: () {
                if (context.locale == localeEnUs) {
                  context.setLocale(localeUkUa);
                } else {
                  context.setLocale(localeEnUs);
                }
              },
            ),
            IconButton(
                icon: Icon(Theme.of(context).brightness == Brightness.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
                onPressed: () {
                  if (Theme.of(context).brightness == Brightness.light) {
                    themeNotifier.value = ThemeMode.dark;
                  } else {
                    themeNotifier.value = ThemeMode.light;
                  }
                }
            ),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        "homepage.quick.search".tr(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "homepage.quick.search.by.title".tr(),
                        ),
                        onChanged: (value) {
                          List<Book> newBooks = [];
                          for (var f in fetchedBooks.books) {
                            if (f.title.contains(value)) {
                              newBooks.add(f);
                            }
                          }
                          booksNotifier.value = BookRepository(newBooks);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: booksNotifier,
                builder: (context, value, child) {
                  if (loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (value.books.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            ':(',
                            style:
                                TextStyle(fontSize: 100, color: Colors.black12),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'homepage.books.not.found'.tr(),
                            style:
                                TextStyle(fontSize: 20, color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }

                  List<Widget> children = [];

                  for (var book in value.books) {
                    children.add(buildBookTile(context, book));
                    children.add(const SizedBox(
                      height: 20,
                    ));
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 20, left: 20, top: 20),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: children,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
