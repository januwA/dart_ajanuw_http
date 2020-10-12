import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart';
import '../ajanuw_http.dart';
import 'ajanuw_http_config.dart';
import 'util/util.dart';

Future<Response> _ajanuwHttp(
  AjanuwHttpConfig cfg, [
  List<AjanuwHttpInterceptors> interceptors,
]) async {
  var f = Completer<Response>();
  handleConfig(cfg);
  assert(cfg.url is Uri);

  // 运行request拦截器
  if (interceptors != null) {
    for (var it in interceptors) {
      if (it == null) continue;
      cfg = await it.request(cfg);
    }
  }

  // 创建request
  var req = createRequest(cfg);

  // 发送
  var client = Client();
  var stream = cfg.timeout == null
      ? await client.send(req)
      : await client.send(req).timeout(cfg.timeout);

  var bytes = <int>[];
  var bytesCompleter = Completer<List<int>>();
  stream.stream.listen(
    cfg.onDownloadProgress == null
        ? (List<int> d) => bytes.addAll(d)
        : (List<int> d) {
            bytes.addAll(d);
            cfg.onDownloadProgress(bytes.length, stream.contentLength);
          },
    onDone: () => bytesCompleter.complete(bytes),
  );

  // 获取response
  var res = Response.bytes(
    await bytesCompleter.future,
    stream.statusCode,
    request: stream.request,
    headers: stream.headers,
    isRedirect: stream.isRedirect,
    persistentConnection: stream.persistentConnection,
    reasonPhrase: stream.reasonPhrase,
  );

  // 运行response拦截器
  if (interceptors != null) {
    for (var it in interceptors) {
      if (it == null) continue;
      res = await it.response(res, cfg);
    }
  }

  // 验证状态码q
  if (cfg.validateStatus == null || cfg.validateStatus(res.statusCode)) {
    f.complete(res);
  } else {
    f.completeError(res);
  }

  client.close();

  return f.future;
}

typedef AjanuwHttpProgress = Function(int bytes, int total);

/// 拦截器基类
abstract class AjanuwHttpInterceptors {
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config);

  Future<Response> response(BaseResponse response, AjanuwHttpConfig config);
}

AjanuwHttpConfig __defaultConfig = AjanuwHttpConfig(
  method: 'get',
  validateStatus: (int status) => status ~/ 100 == 2,
);

class AjanuwHttp {
  /// 默认配置
  AjanuwHttpConfig config;

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
  AjanuwHttp([AjanuwHttpConfig _defaultConfig]) {
    // 将每次构造的config与[defaultConfig]的合并
    config = _defaultConfig != null
        ? _defaultConfig.merge(__defaultConfig)
        : __defaultConfig.merge(AjanuwHttpConfig());
  }

  /// 所有拦截器
  List<AjanuwHttpInterceptors> interceptors = [];

  Future<Response> request(AjanuwHttpConfig config) {
    // 将每次请求的[config]和构建是的[this.config]合并
    return _ajanuwHttp(config.merge(this.config), interceptors);
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
