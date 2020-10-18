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
  var r = await api.get(
    Uri.parse('/'),
    AjanuwHttpConfig(params: {'name': 'Ajanuw'}),
  );
  print(r.body);
}
```

## Get File
```dart
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
```

## send file
```dart
import 'dart:io';

import 'package:ajanuw_http/ajanuw_http.dart';

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
```

## Use interceptor
```dart
import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart';

class HeaderInterceptor extends AjanuwHttpInterceptors {
  @override
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config) async {
    config.headers ??= {};

    if (config.method.toLowerCase() == 'post' && config.body is Map) {
      (config.body as Map)['x-key'] = 'key';
    }

    config.headers.addAll({'x-senduser': 'ajanuw'});
    return config;
  }

  @override
  Future<BaseResponse> response(BaseResponse response, _) async {
    return response;
  }
}

void main() async {
  var api = AjanuwHttp()
    ..config.baseURL = 'http://localhost:3000/api/'
    ..interceptors.add(HeaderInterceptor());
  var r = await api.post('/', AjanuwHttpConfig(body: {'name': 'ajanuw'}));
  print(r.body);
}
```

## Use rxdart for error retry
```dart
import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';
  Rx.retry<Response>(() {
    return api.get('/retry').asStream().map((r) {
      if (r.statusCode != 200) return throw Stream.error(r);
      return r;
    });
  }, 5)
      .listen(
    (r) => print(r.body),
    onError: (er) => print(er),
  );
}
```

## Fetch request error
```dart
try {
  var r = await api.get('');
  print(r.body);
} catch (e) {
  print( (e as Response).body );
}
```

## test
```sh
> pub run test
> pub run test .\test\ajanuw_http_test.dart
```


See also:
- [Examples](https://github.com/januwA/dart_ajanuw_http/tree/master/example)