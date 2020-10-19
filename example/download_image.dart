import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';

var api = AjanuwHttp();
var url = 'https://i.loli.net/2020/01/14/w1dcNtf4SECG6yX.jpg';

void main() async {
  try {
    var r = await api.getStream(
      url,
      AjanuwHttpConfig(
        onDownloadProgress: (bytes, total) {
          print((bytes / total * 100).toInt().toString() + '%');
        },
      ),
    );
    var f$ = File('./test.jpg').openWrite();
    r.stream.listen(
      f$.add,
      onDone: () {
        f$.close();
        print('done.');
      },
      onError: (e) => f$.close(),
    );
  } catch (e) {
    print(e.runtimeType);
    print('Error: ' + e.message);
  }
}
