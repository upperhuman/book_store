import 'dart:convert';
import 'dart:io';

import 'package:book_store_front/main.dart';
import 'package:book_store_front/order_dto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

import 'book_repository.dart';

class ShoppingCartDialog extends StatefulWidget {

  final void Function() setStateCallback;

  final void Function(SnackBar snackBar) showSnackBarCallback;

  const ShoppingCartDialog(this.setStateCallback, this.showSnackBarCallback, {super.key});

  @override
  State<ShoppingCartDialog> createState() => _ShoppingCartDialogState();
}

class _ShoppingCartDialogState extends State<ShoppingCartDialog> {

  @override
  void initState() {
    super.initState();
  }

  double calculateCostTotal() {
    double total = 0;
    for (var e in orderEntities) {
      total += e.getCostTotal();
    }

    return total;
  }

  void deleteEntity(BookOrderEntity entity) {
    setState(() {
      orderEntities.remove(entity);
    });

    widget.setStateCallback();
  }

  void incrementCount(BookOrderEntity entity) {
    setState(() {
      entity.incrementCount();
    });
  }

  void decrementCount(BookOrderEntity entity) {
    setState(() {
      entity.decrementCount();
    });
  }

  void changeCount(BookOrderEntity entity, String text) {
    int? count = int.tryParse(text);
    if (count == null) {
      return;
    }

    setState(() {
      entity.countController.text = count.toString();
    });
  }

  void toOrder() async {
    if(credentials != null) {
      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: credentials!,
      };
      List<OrderEntryDto> list = [];
      for (var i in orderEntities) {
        list.add(OrderEntryDto(i.book.title, i.count, i.getCostTotal()));
      }
      OrderDto order = OrderDto(list);
      var post = await http.post(Uri.parse('http://localhost:8081/buy'),
          body: jsonEncode(order.toMap()),
          headers: headers
      );

      setState(() {
        orderEntities.clear();
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.showSnackBarCallback(
          SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                        text: "order.submit".tr(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )
                    ),
                  ),
                ],
              )
          )
      );

    }
    else{
      if (!mounted) return;
      Navigator.pop(context);
      widget.showSnackBarCallback(
          SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange,),
                  const SizedBox(width: 10,),
                  RichText(
                    text: TextSpan(
                        text: "need.to.login".tr(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )
                    ),
                  ),
                ],
              )
          )
      );
    }
  }


  Widget buildBookTile(BuildContext context, BookOrderEntity entity, int index) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black12,
      height: 220,
      child: Stack(
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child:
                  entity.book.previewBytes.isEmpty
                      ? const Center(
                        child: Text("?", style: TextStyle(fontSize: 24),),
                  )
                      : Image.memory(
                    entity.book.previewBytes,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.book.title,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                          entity.book.description

                      ),
                      const SizedBox(height: 10,),
                      Text(
                        entity.book.author,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ]
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    deleteEntity(entity);
                  },
                  icon: const Icon(
                      Icons.delete,
                      color: Colors.red
                  )
              ),
              const SizedBox(
                height: 50,
              ),
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  Text(
                      'page.shopping_cart.price'.tr(),
                      style: const TextStyle(
                          fontSize: 14, fontStyle: FontStyle.italic)),
                  IconButton(
                    onPressed: () => decrementCount(entity),
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 30,
                    child: TextField(
                        textAlign: TextAlign.center,
                        controller: entity.countController,
                        onChanged: (value){
                          if(int.parse(value) is int) {
                            setState(() {
                               entity.count = int.parse(value);
                            });
                          }
                        },
                    ),
                  ),
                  IconButton(
                    onPressed: () => incrementCount(entity),
                    icon: const Icon(Icons.add),
                  ),
                  Text('page.shopping_cart.of_books'.tr()
                    , style: const TextStyle
                        (fontSize: 14, fontStyle: FontStyle.italic
                      ),
                  ),
                  Text('${entity.getCostTotal().toStringAsFixed(2)} ₴',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.cyan
                            : Colors.purple,
                      )
                  ),
                  const SizedBox(width: 20,)
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBooksWidget(BuildContext context) {
    if (orderEntities.isEmpty) {
      return SizedBox(
        height: 600,
        child: Center(
          child: Text(
            "page.shopping_cart.is.empty".tr(),
            style: const TextStyle(
              fontSize: 20
            )
          ),
        ),
      );
    }

    List<Widget> children = [];

    for (int i = 0; i < orderEntities.length; i++) {
      children.add(buildBookTile(context, orderEntities[i], i));
      children.add(const SizedBox(height: 20,));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const ContinuousRectangleBorder(),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 900,
          minHeight: 600,
          //maxHeight: MediaQuery.of(context).size.height - 80,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text("page.shopping_cart".tr(),
                    style: const TextStyle(
                      fontSize: 18
                    )
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: buildBooksWidget(context),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: const ShapeDecoration(
                    shape: StadiumBorder(),
                    color: Color.fromRGBO(105, 207, 210, 0.3)
                  ),
                  child: TextButton(
                    onPressed:
                    orderEntities.isEmpty
                      ? null
                      : () => toOrder(),
                    child:
                    Text(
                      'page.shopping_cart.order'.tr(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w100,
                      ),

                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}



