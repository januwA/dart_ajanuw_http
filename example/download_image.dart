import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';

var api = AjanuwHttp();
var url = 'https://i.loli.net/2020/01/14/w1dcNtf4SECG6yX.jpg';

void main() async {
  try {
    var r = await api.getStream(url);
    var f$ = File('./test.jpg').openWrite();
    await f$.addStream(r.stream);
    await f$.close();
    print('done.');
  } catch (e) {
    print('Error: ' + e.message);
  }
}
