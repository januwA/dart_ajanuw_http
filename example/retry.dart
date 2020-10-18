import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';
  Rx.retry<Response>(() {
    return api.get('/retry').asStream().map((r) {
      if (r.statusCode != 200) return throw Stream.error(r);
      return r;
    });
  }, 5)
      .listen(
    (r) => print(r.body),
    onError: (er) => print(er),
  );
}
