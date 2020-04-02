import 'dart:async';
import 'dart:typed_data';

import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart';

import './ajanuw_http_config.dart';
import 'util/util.dart';

typedef AjanuwHttpProgress = Function(int bytes, int total);

/// 拦截器基类
abstract class AjanuwHttpInterceptors {
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config);

  Future<Response> response(BaseResponse response);
}

AjanuwHttpConfig defaultConfig = AjanuwHttpConfig(
  method: 'get',
  validateStatus: (int status) => status ~/ 100 == 2,
);

///
///```dart
///import 'package:ajanuw_http/ajanuw_http.dart';
///
/// void main() async {
///   var api = AjanuwHttp()..config.baseURL = 'http://localhost:3000/api/';
///   var r = await api.get('/cats');
///   print(r.body);
/// }
///```
///
class AjanuwHttp {
  /// 默认配置
  AjanuwHttpConfig config;
  AjanuwHttp([AjanuwHttpConfig _defaultConfig]) {
    // 将每次构造的config与[defaultConfig]的合并
    if (_defaultConfig != null) {
      config = _defaultConfig.merge(defaultConfig);
    } else {
      config = defaultConfig;
    }
  }

  /// 所有拦截器
  List<AjanuwHttpInterceptors> interceptors = [];

  Future<Response> request(AjanuwHttpConfig config) {
    // 将每次请求的[config]和构建是的[this.config]合并
    return ajanuwHttp(config.merge(this.config), interceptors);
  }

  Future<Response> head(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'head'
          ..url = url,
      );

  Future<Response> get(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'get'
          ..url = url,
      );

  /// send file
  ///
  /// ```dart
  /// import 'dart:io';
  /// import 'package:async/async.dart';
  /// import 'package:http_interceptor/http_interceptor.dart';
  /// import 'package:image_picker/image_picker.dart';
  /// import 'package:http/http.dart';
  /// import 'package:path/path.dart';
  ///
  ///// Create http sender
  /// HttpClientWithInterceptor client = HttpClientWithInterceptor.build(
  ///   interceptors: [
  ///     BaseUrlInterceptor(),
  ///   ],
  /// );
  ///
  /// // Create an interceptor that will stitch the url
  /// class BaseUrlInterceptor implements InterceptorContract {
  ///   final baseUrl = "http://192.168.1.91:5000";
  ///   @override
  ///   Future<RequestData> interceptRequest({RequestData data}) async {
  ///     data.url = Uri.parse(baseUrl.toString() + data.url.toString());
  ///     return data;
  ///   }
  ///   @override
  ///   Future<ResponseData> interceptResponse({ResponseData data}) async {
  ///     return data;
  ///   }
  /// }
  ///
  /// floatingActionButton: FloatingActionButton(
  ///   child: Icon(Icons.add),
  ///   onPressed: () async {
  ///     // Get image
  ///     File imageFile =  await ImagePicker.pickImage(source: ImageSource.gallery);
  ///     if (imageFile != null) {
  ///       var stream = ByteStream(
  ///         DelegatingStream.typed(imageFile.openRead()),
  ///       );
  ///       int length = await imageFile.length();
  ///       MultipartFile file = MultipartFile(
  ///         'file',
  ///         stream,
  ///         length,
  ///         filename: basename(imageFile.path),
  ///       );
  ///       // send
  ///       var r = await client.postFile(
  ///        "/upload",
  ///         body: {
  ///           'name': 'foo',
  ///         },
  ///         files: [file],
  ///       );
  ///       print(r.statusCode);
  ///       print(r.body);
  ///     }
  ///   },
  /// ),
  /// ```
  Future<Response> post(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'post'
          ..url = url,
      );

  Future<Response> put(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'put'
          ..url = url,
      );

  Future<Response> patch(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'patch'
          ..url = url,
      );

  Future<Response> delete(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'delete'
          ..url = url,
      );

  Future<String> read(url, [AjanuwHttpConfig config]) async {
    final response = await get(url, config);
    return response.body;
  }

  Future<Uint8List> readBytes(url, [AjanuwHttpConfig config]) async {
    final response = await get(url, config);
    return response.bodyBytes;
  }
}
