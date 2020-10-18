import 'package:ajanuw_http/ajanuw_http.dart';

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';
  var r = await api.post(
    '/',
    AjanuwHttpConfig(body: {'name': 'Suou'}),
  );
  print(r.body);
}
