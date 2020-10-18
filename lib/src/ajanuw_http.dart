import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'ajanuw_http_client.dart';
import 'ajanuw_http_config.dart';
import 'util/util.dart';

Future<T> _ajanuwHttp<T extends BaseResponse>(
  AjanuwHttpConfig cfg, [
  List<AjanuwHttpInterceptors> interceptors,
]) async {
  var f = Completer<T>();
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
  var client = AjanuwHttpClient();
  var streamResponse = cfg.timeout == null
      ? await client.send(req)
      : await client.send(req).timeout(cfg.timeout);

  T res;

  if (cfg.httpFutureType == HttpFutureType.Response) {
    var bytesLength = 0;
    streamResponse.stream.listen(
      cfg.onDownloadProgress == null
          ? (_) {}
          : (List<int> d) {
              bytesLength += d.length;
              cfg.onDownloadProgress(bytesLength, streamResponse.contentLength);
            },
    );
    res = await Response.fromStream(streamResponse) as T;
  } else {
    res = streamResponse as T;
  }

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

  return f.future;
}

/// 拦截器基类
abstract class AjanuwHttpInterceptors {
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config);

  Future<BaseResponse> response(BaseResponse response, AjanuwHttpConfig config);
}

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
  AjanuwHttp() {
    config = AjanuwHttpConfig()
      ..method = 'get'
      ..httpFutureType = HttpFutureType.Response
      ..validateStatus = (int status) => status ~/ 100 == 2;
  }

  /// 所有拦截器
  List<AjanuwHttpInterceptors> interceptors = [];

  Future<Response> request(AjanuwHttpConfig config) {
    // 将当前请求的[config]和全局的[config]合并
    return _ajanuwHttp<Response>(config.merge(this.config), interceptors);
  }

  Future<StreamedResponse> requestStream(AjanuwHttpConfig config) {
    // 将当前请求的[config]和全局的[config]合并
    return _ajanuwHttp<StreamedResponse>(
        config.merge(this.config)
          ..httpFutureType = HttpFutureType.StreamedResponse,
        interceptors);
  }

  Future<Response> head(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'head'
          ..url = url,
      );

  Future<StreamedResponse> headStream(url, [AjanuwHttpConfig config]) =>
      requestStream(
        createConfig(config)
          ..method = 'head'
          ..url = url,
      );

  Future<Response> get(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'get'
          ..url = url,
      );

  Future<StreamedResponse> getStream(url, [AjanuwHttpConfig config]) =>
      requestStream(
        createConfig(config)
          ..method = 'get'
          ..url = url,
      );

  Future<Response> post(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'post'
          ..url = url,
      );

  Future<StreamedResponse> postStream(url, [AjanuwHttpConfig config]) =>
      requestStream(
        createConfig(config)
          ..method = 'post'
          ..url = url,
      );

  Future<Response> put(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'put'
          ..url = url,
      );
  Future<StreamedResponse> putStream(url, [AjanuwHttpConfig config]) =>
      requestStream(
        createConfig(config)
          ..method = 'put'
          ..url = url,
      );

  Future<Response> patch(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'patch'
          ..url = url,
      );

  Future<StreamedResponse> patchStream(url, [AjanuwHttpConfig config]) =>
      requestStream(
        createConfig(config)
          ..method = 'patch'
          ..url = url,
      );

  Future<Response> delete(url, [AjanuwHttpConfig config]) => request(
        createConfig(config)
          ..method = 'delete'
          ..url = url,
      );

  Future<StreamedResponse> deleteStream(url, [AjanuwHttpConfig config]) =>
      requestStream(
        createConfig(config)
          ..method = 'delete'
          ..url = url,
      );

  Future<String> read(url, [AjanuwHttpConfig config]) async {
    final response = await get(
        url, createConfig(config)..httpFutureType = HttpFutureType.Response);
    return response.body;
  }

  Future<Uint8List> readBytes(url, [AjanuwHttpConfig config]) async {
    final response = await get(
        url, createConfig(config)..httpFutureType = HttpFutureType.Response);
    return response.bodyBytes;
  }
}
