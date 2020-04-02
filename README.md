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
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';
  var r = await api.get('/cats');
  print(r.body);
}
```

## Post
```dart
import 'package:ajanuw_http/ajanuw_http.dart';

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';
  var r2 = await api.post('/cats');
  print(r2.body);
}
```

## send file
```dart
import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:http_parser/http_parser.dart' show MediaType;

void main() async {
import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:http_parser/http_parser.dart' show MediaType;

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api';

  var r = await api.post(
    '/upload',
    AjanuwHttpConfig(
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
```

## Use interceptor
```dart
import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart';

class HeaderInterceptor extends AjanuwHttpInterceptors {
  @override
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config) async {
    if (config.method.toLowerCase() == 'post' && config.body is Map) {
      (config.body as Map)['x-key'] = '拦截器数据';
    }
    return config;
  }

  @override
  Future<Response> response(BaseResponse response) async {
    return response;
  }
}

void main() async {
  var api = AjanuwHttp()
    ..config.baseURL = 'http://localhost:3000/api/'
    ..interceptors.add(HeaderInterceptor());

  var r = await api.post('/cats', AjanuwHttpConfig(body: {'name': 'ajanuw'}));

  print(r.body);
}
```

## Use rxdart for error retry
```dart
import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  var api = AjanuwHttp()
    ..config.baseURL = 'http://localhost:3000/api/';

  Rx.retry(() {
    return Stream.fromFuture(api.get('/cats')).map((r) {
      print(r.statusCode);
      if (r.statusCode != 200) {
        throw Stream.error('send a err');
      }
      return r;
    });
  }, 3)
      .listen(
    (r) {
      print(r.body);
    },
    onError: (er) {
      // If all three fail
      print('Error: $er');
    },
  );
}
```

If you execute the above example, you may see the following result:
```sh
λ dart ./example/ajanuw_http_example.dart
403
403
200
Hello World!
```

## test
```sh
> pub run test
> pub run test .\test\ajanuw_http_test.dart
```