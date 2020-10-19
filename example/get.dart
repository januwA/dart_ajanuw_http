import 'package:ajanuw_http/ajanuw_http.dart';

void main() {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';

  api
      .get(
    Uri.parse('/'),
    AjanuwHttpConfig(
      params: {'name': 'Ajanuw'},
    ),
  )
      .then((r) {
    print(r.body);
  }).catchError((e) {
    print(e.runtimeType);
  });
}
