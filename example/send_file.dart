import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart';

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api';

  var r = await api.post(
    '/upload',
    AjanuwHttpConfig(
      body: {'data': '111'},
      files: [
        await MultipartFile.fromPath('file', './a.jpg'),
        MultipartFile.fromBytes(
          'file',
          await File('./a.jpg').readAsBytes(),
          contentType: MediaType('image', 'jpeg'),
          filename: 'a.jpg',
        ),
        MultipartFile.fromBytes(
          'file',
          await api
              .readBytes('https://i.loli.net/2019/10/01/CVBu2tNMqzOfXHr.png'),
          contentType: MediaType('image', 'png'),
          filename: 'CVBu2tNMqzOfXHr.png',
        ),
      ],
    ),
  );
  print(r.body);
}
