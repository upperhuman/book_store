import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:book_store_front/home_page.dart';
import 'package:book_store_front/order_dto.dart';
import 'package:book_store_front/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'login_dialog.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  ValueNotifier<List<OrderFullDto>> ordersNotifier = ValueNotifier([]);

  @override
  void initState() {
    loadOrders();
    super.initState();
  }

  void loadOrders() async {
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: credentials!,
    };

    var response = await http.get(Uri.parse('http://localhost:8081/order/all'),
        headers: headers);

    List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));

    List<OrderFullDto> orders = [];

    for (var item in list) {
      Map<String, dynamic> map = item;
      orders.add(OrderFullDto.fromMap(map));
    }

    ordersNotifier.value = orders;

    for (int entry = 0; entry < ordersNotifier.value.length; entry++) {
      for (int entry2 = 0;
          entry2 < ordersNotifier.value[entry].orderEntries.length;
          entry2++) {
        var response = await http.get(
            Uri.parse(
                'http://localhost:8081/book/img/get?title=${ordersNotifier.value[entry].orderEntries[entry2].bookName}'),
            headers: headers);
        if (response.headers.containsKey(HttpHeaders.contentTypeHeader) &&
            response.headers[HttpHeaders.contentTypeHeader] == 'image/png') {
          setState(() {
            ordersNotifier.value[entry].orderEntries[entry2].img =
                response.bodyBytes;
          });
        }
      }
    }
  }

  double orderCost(OrderFullDto order) {
    double cost = 0;
    for (var entries in order.orderEntries) {
      cost += entries.cost;
    }
    return cost;
  }

  Widget expansionTileRow(BuildContext context, OrderEntryDto order) {
    return Row(
      children: [
        const SizedBox(
          width: 30,
        ),
        order.img.isEmpty
            ? const Center(
                child: SizedBox(
                    width: 35,
                    height: 50,
                    child: Text(
                      "?",
                      style: TextStyle(fontSize: 24),
                    )),
              )
            : SizedBox(
                width: 35,
                child: Image.memory(order.img),
              ),
        const SizedBox(width: 20),
        SizedBox(width: 300, child: Text(order.bookName)),
        const Spacer(),
        SizedBox(width: 100, child: Text(order.count.toString())),
        const Spacer(),
        SizedBox(width: 150, child: Text("${order.cost.toStringAsFixed(2)} ₴")),
      ],
    );
  }

  List<Widget> expansionTileRowList(BuildContext context, OrderFullDto order) {
    List<Widget> list = [];

    list.add(const SizedBox(
      height: 20,
    ));
    list.add(Row(
      children: [
        const SizedBox(
          width: 30,
        ),
        const SizedBox(
          width: 120,
        ),
        SizedBox(width: 300, child: Text('book.name'.tr())),
        const Spacer(),
        SizedBox(width: 100, child: Text('count'.tr())),
        const Spacer(),
        SizedBox(width: 150, child: Text('cost'.tr())),
      ],
    ));
    list.add(const SizedBox(
      height: 20,
    ));
    for (var i in order.orderEntries) {
      list.add(expansionTileRow(context, i));
      list.add(const SizedBox(
        height: 20,
      ));
    }
    return list;
  }

  Widget buildOrder(BuildContext context, OrderFullDto order) {
    return ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 50,
              color: order.state == "success"
                  ? Colors.lightGreen
                  : Colors.yellowAccent,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("№${order.orderId}"), Text(order.state)],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("order.cost".tr()),
                Text("${orderCost(order)} ₴")
              ],
            ),
            const Spacer(
              flex: 2,
            ),
          ],
        ),
        children: expansionTileRowList(context, order));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'my.orders'.tr(),
        ),
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
                          toEditBookPage(context, null);
                        }

                        if (item == "logout") {
                          currentUserNotifier.value = User.anonymous;
                          credentials = null;
                        }

                        if (item == "orders_history") {
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
                      }),
                ],
              );
            },
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
              onPressed: () => showShoppingCartDialog(context, setState),
              icon: const Icon(Icons.shopping_cart)),
          const SizedBox(
            width: 10,
          ),
          TextButton(
            child: Text(context.locale == localeEnUs ? 'EN' : 'UA'),
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
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 900,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
              child: ValueListenableBuilder(
                  valueListenable: ordersNotifier,
                  builder: (context, value, child) {
                    if (value.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              ':(',
                              style: TextStyle(
                                  fontSize: 100, color: Colors.black12),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'orders.not.found'.tr(),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black54),
                            ),
                          ],
                        ),
                      );
                    }

                    List<Widget> children = [];

                    for (var order in value) {
                      children.add(buildOrder(context, order));
                      children.add(const SizedBox(
                        height: 20,
                      ));
                    }
                    return Column(
                      children: children,
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
