import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:http_parser/http_parser.dart' show MediaType;

void main() async {
  AjanuwHttp.basePath = 'http://localhost:3000';
  var r = await '/upload'.postFile(
    params: {'name': 'ajanuw'},
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
        await 'https://i.loli.net/2019/10/01/CVBu2tNMqzOfXHr.png'.readBytes(),
        contentType: MediaType('image', 'png'),
        filename: 'CVBu2tNMqzOfXHr.png',
      ),
    ],
  );
  print(r.body);
}
