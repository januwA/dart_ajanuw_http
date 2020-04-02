import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  var api = AjanuwHttp()
    ..config.baseURL = 'http://localhost:3000/api/';

  Rx.retry(() {
    return Stream.fromFuture(api.get('/cats')).map((r) {
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
