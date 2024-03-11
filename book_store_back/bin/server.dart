import 'package:shelf_router/shelf_router.dart' as router;
import 'package:shelf/shelf_io.dart' as io;

import 'auth_provider.dart';
import 'book_repository.dart';
import 'endpoint_buy_book.dart';
import 'endpoint_get_book_all.dart';
import 'endpoint_get_book.dart';
import 'endpoint_get_orders.dart';
import 'endpoint_get_user.dart';
import 'endpoint_post_book.dart';
import 'endpoint_delete_book.dart';
import 'order_service.dart';
import 'user_service.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'endpoint_post_preview.dart';
import 'endpoint_get_preview.dart';

final userService = UserService();
final authProvider = AuthProvider(userService);
final bookRepository = BookRepository();
final orderService = OrderService();


void main(List<String> args) async {
  final app = router.Router();

  app.get('/book', getBook);

  app.get('/book/all', getBookAll);

  app.post('/book', postBook);

  app.post("/delete", deleteBook);

  app.get('/user', getUser);

  app.post('/buy', buyBook);

  app.get('/order/all', getOrders);

  app.post('/book/img/post', postPreview);
  app.get('/book/img/get', getPreview);

  app.all('/<ignored|.*>', (shelf.Request request) {
    Map<String, String> headers = {};
    addCorsPolicyHeaders(headers);

    if (request.method == 'OPTIONS') {
      return shelf.Response.ok(null, headers: headers);
    }
    return shelf.Response.notFound(null, headers: headers);
  });


  var server = await io.serve(app, 'localhost', 8081);

  print('Serving at http://${server.address.host}:${server.port}');

  await bookRepository.loadFromDisk();

  await userService.loadAll();

}

void addCorsPolicyHeaders(Map<String, String> headers) {
  headers.addAll({
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*',
  });
}






