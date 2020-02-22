import 'package:rxdart/rxdart.dart';
import 'package:ajanuw_http/ajanuw_http.dart';

void main() async {
  AjanuwHttp.basePath = 'http://localhost:3000';

  Rx.retry(() {
    return Stream.fromFuture('/'.get()).map((r) {
      print(r.statusCode);
      if (r.statusCode != 200) {
        throw Stream.error('send a err');
      }
      return r;
    });
  }, 3)
      .listen(
    (r) {
      print(r.body);
    },
    onError: (er) {
      // If all three fail
      print('Error: $er');
    },
  );
}
