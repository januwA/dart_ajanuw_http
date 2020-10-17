import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';

  var r = await api.getStream('/');
  // await File('./a.txt').openWrite().addStream(r.stream);

  var f1 = File('./a.txt').openWrite();
  var f2 = File('./b.txt').openWrite();

  r.stream.listen(
    (List<int> d) {
      f1.add(d);
      f2.add(d);
    },
    onDone: () {
      f1.close();
      f2.close();
    },
  );
}
