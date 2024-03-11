import 'dart:convert';

import 'order_service.dart';

class OrderEntryDto{
  final String bookName;
  final int count;
  final double cost;

  OrderEntryDto(this.bookName, this.count, this.cost);


  OrderEntryDto.fromMap(Map<String, dynamic> map)
      : bookName = map['bookName'],
        count = map["count"],
        cost = map["cost"];

  Map<String, dynamic> toMap() {
    return {
      'bookName': bookName,
      'count': count,
      'cost': cost
    };
  }
}
class OrderDto{
  late List<OrderEntryDto> orderEntries;

  OrderDto(this.orderEntries);
  OrderDto.fromMap(Map<String, dynamic> map){
    orderEntries = [];
    List<dynamic> list = map['orderEntries'];
    for(Map<String, dynamic> m in list){
      orderEntries.add(OrderEntryDto.fromMap(m));
    }
  }
  Map<String, dynamic> toMap(){
    List<Map<String, dynamic>> list = [];
    for(var order in orderEntries){
      list.add(order.toMap());
    }
    return {
      "orderEntries": list
    };
  }
}
class OrderFullDto{

  final String date;
  final String state;
  final int orderId;
  final String username;

  late List<OrderEntryDto> orderEntries;

  OrderFullDto(this.date, this.state, this.orderId, this.username, this.orderEntries);
  OrderFullDto.fromMap(Map<String, dynamic> map)
  :
        date = map['date'],
        state = map['state'],
        orderId = map['orderId'],
        username = map['username']
  {
    orderEntries = [];
    List<dynamic> list = map['orderEntries'];
    for(Map<String, dynamic> m in list){
      orderEntries.add(OrderEntryDto.fromMap(m));
    }
  }
  Map<String, dynamic> toMap(){
    List<Map<String, dynamic>> list = [];
    for(var order in orderEntries){
      list.add(order.toMap());
    }
    return {
      "orderEntries": list,
      "date": date,
      "state": state,
      "orderId": orderId,
      "username": username
    };
  }
  String toJsonString([JsonEncoder? encoder]) {
    return (encoder ?? JsonEncoder.withIndent('  ')).convert(toMap());
  }
}