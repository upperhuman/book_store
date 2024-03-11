
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'order_dto.dart';
import 'server.dart';
import 'user_service.dart';

class OrderService {

  static const rootPath = 'orders';

  static final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final dateFormatFile = DateFormat('yyyy_MM_dd_HH_mm_ss');


  Future<void> submitOrder(User user, OrderDto dto) async {
    for (var entry in dto.orderEntries) {
      if (!bookRepository.existByTitle(entry.bookName)) {
        throw Exception('Book not found: ${entry.bookName}');
      }
    }
    Random r = Random();
    final order = OrderFullDto(dateFormat.format(DateTime.now()), 'success', r.nextInt(1000000000), user.username, dto.orderEntries);

    if (! await Directory(rootPath).exists()) {
      await Directory(rootPath).create();
    }

    final file = File('$rootPath/${dateFormatFile.format(DateTime.now())}@${user.username}.json');
    await file.writeAsString(order.toJsonString());
  }

  Future <List<OrderFullDto>> getOrdersForUser(User user) async {
    final dir = Directory(rootPath);

    if (! await dir.exists()) {
      await dir.create();
    }

    final files = dir.listSync();
    List<OrderFullDto> orders = [];
    for (var file in files) {
      if (file is File) {
        File f = file;
        String filename = path.basename(f.path);
        if (filename.contains('@${user.username}')) {
          final jsonString = await file.readAsString();
          final order = OrderFullDto.fromMap(jsonDecode(jsonString));
          orders.add(order);
        }
      }
    }

    return orders;
  }

}