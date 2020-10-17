import 'package:ajanuw_http/ajanuw_http.dart';

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';

  var r = await api.get(Uri.parse('/'));
  print(r.body);

  // var r2 = await api.post('/cats');
  // print(r2.body);
}
