import 'package:ajanuw_http/src/ajanuw_http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ajanuw_http/ajanuw_http.dart';

void main() async {
  // var r = await ajanuwHttp(AjanuwHttpConfig(
  //   url: 'http://localhost:3000/api/cats?age=12',
  //   params: {
  //     'name': 'ajanuw',
  //     'arr': ['1', '2']
  //   },
  // ));
  // print(r.body);

  // var r = await ajanuwHttp(AjanuwHttpConfig(
  //   method: 'post',
  //   url: 'http://localhost:3000/api/cats',
  //   body: {
  //     'name': 'ajanuw'
  //   }
  // ));
  // print(r.body);

  // AjanuwHttp.basePath = 'http://localhost:3000';

  // Rx.retry(() {
  //   return Stream.fromFuture('/'.get()).map((r) {
  //     print(r.statusCode);
  //     if (r.statusCode != 200) {
  //       throw Stream.error('send a err');
  //     }
  //     return r;
  //   });
  // }, 3)
  //     .listen(
  //   (r) {
  //     print(r.body);
  //   },
  //   onError: (er) {
  //     // If all three fail
  //     print('Error: $er');
  //   },
  // );
}
