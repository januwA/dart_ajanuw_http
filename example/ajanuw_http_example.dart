import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';
  Rx.retry(() {
    return api.get('').asStream().map((r) {
      if (r.statusCode != 200) {
        throw Stream.error(r);
      }
      return r;
    }).doOnError((error, stacktrace) {
      return error;
    });
  }, 3)
      .listen(
    (r) => print(r.body),
    onError: (er) => print(er),
  );
}
