## A http interceptor in dart

## Install
```yaml
dependencies:
  ajanuw_http:
```

## Get
```dart
import 'package:ajanuw_http/ajanuw_http.dart';

void main() async {
  AjanuwHttp.basePath = 'http://localhost:3000';
  var r = await '/'.get(
    params: {'name': 'ajanuw'},
  );
  print(r.body);
}
```

## Post
```dart
import 'package:ajanuw_http/ajanuw_http.dart';

void main() async {
  AjanuwHttp.basePath = 'http://localhost:3000';
  var r = await '/'.post(
    params: {'name': 'ajanuw'},
    body: {'data': '111'},
  );
  print(r.body);
}
```

## send file
```dart
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
```

## Use interceptor
```dart
import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/src/base_request.dart';
import 'package:http/src/base_response.dart';
import 'package:http/src/request.dart';
import 'package:http/src/response.dart';

void main() async {
  AjanuwHttp.basePath = 'http://localhost:3000';
  AjanuwHttp.interceptors.add(HeaderInterceptor());
  var r = await '/'.get(
    params: {'name': 'ajanuw'},
  );
  print(r.body);
}

class HeaderInterceptor extends AjanuwHttpInterceptors {
  @override
  Future<Request> request(BaseRequest request) async {
    request.headers['X-myname'] = 'ajanuw';
    return request;
  }

  @override
  Future<Response> response(BaseResponse response) async {
    return response;
  }
}
```

## test
```sh
> pub run test
> pub run test .\test\ajanuw_http_test.dart
```