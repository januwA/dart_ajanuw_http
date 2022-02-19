import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'ajanuw_http_client.dart';
import 'ajanuw_http_config.dart';
import 'util/util.dart';

Future<T> _ajanuwHttp<T extends BaseResponse>(AjanuwHttpConfig cfg) async {
  var client = AjanuwHttpClient();

  cfg.method ??= 'get';
  cfg.responseType ??= ResponseType.Response;
  cfg.validateStatus ??= (int status) => status ~/ 100 == 2;

  // ignore: unawaited_futures
  cfg.close?.future.then((value) => client.close());

  var f = Completer<T>();
  handleConfig(cfg);
  assert(cfg.url is Uri);

  if (cfg.interceptors != null) {
    // 运行request拦截器
    for (var it in cfg.interceptors!) {
      if (it == null) continue;
      cfg = await it.request(cfg);
    }
  }

  // 创建request
  var req = createRequest(cfg);

  // 发送
  var streamResponse = cfg.timeout == null
      ? await client.send(req)
      : await client.send(req).timeout(cfg.timeout!);

  T res;

  // 监听下载进度
  var bytesLength = 0;
  streamResponse.stream.listen(
    cfg.onDownloadProgress == null
        ? (_) {}
        : (List<int> d) {
            bytesLength += d.length;
            cfg.onDownloadProgress!(
                bytesLength, streamResponse.contentLength ?? 0);
          },
    onDone: client.close,
  );

  if (cfg.responseType == ResponseType.Response) {
    res = await Response.fromStream(streamResponse) as T;
  } else if (cfg.responseType == ResponseType.StreamedResponse) {
    res = streamResponse as T;
  } else {
    throw '意外的返回类型: ${cfg.responseType}';
  }

  if (cfg.interceptors != null) {
    // 运行response拦截器
    for (var it in cfg.interceptors!) {
      if (it == null) continue;
      res = await it.response(res, cfg) as T;
    }
  }

  // 验证状态码
  if (cfg.validateStatus!(res.statusCode)) {
    f.complete(res);
  } else {
    f.completeError(res);
  }

  return f.future;
}

class AjanuwHttp {
  /// 默认配置
  AjanuwHttpConfig config = AjanuwHttpConfig();

  /// 所有拦截器
  List<AjanuwHttpInterceptors> interceptors = [];

  Future<Response> request(AjanuwHttpConfig config) => _ajanuwHttp<Response>(
      config.merge(this.config)..interceptors!.addAll(interceptors));

  Future<StreamedResponse> requestStream(AjanuwHttpConfig config) =>
      _ajanuwHttp<StreamedResponse>(config.merge(this.config)
        ..responseType = ResponseType.StreamedResponse
        ..interceptors!.addAll(interceptors));

  Future<Response> head(url, [AjanuwHttpConfig? config]) => request(
        createConfig(config)
          ..method = 'head'
          ..url = url,
      );

  Future<StreamedResponse> headStream(url, [AjanuwHttpConfig? config]) =>
      requestStream(
        createConfig(config)
          ..method = 'head'
          ..url = url,
      );

  Future<Response> get(url, [AjanuwHttpConfig? config]) => request(
        createConfig(config)
          ..method = 'get'
          ..url = url,
      );

  Future<StreamedResponse> getStream(url, [AjanuwHttpConfig? config]) =>
      requestStream(
        createConfig(config)
          ..method = 'get'
          ..url = url,
      );

  Future<Response> post(url, [AjanuwHttpConfig? config]) => request(
        createConfig(config)
          ..method = 'post'
          ..url = url,
      );

  Future<StreamedResponse> postStream(url, [AjanuwHttpConfig? config]) =>
      requestStream(
        createConfig(config)
          ..method = 'post'
          ..url = url,
      );

  Future<Response> put(url, [AjanuwHttpConfig? config]) => request(
        createConfig(config)
          ..method = 'put'
          ..url = url,
      );
  Future<StreamedResponse> putStream(url, [AjanuwHttpConfig? config]) =>
      requestStream(
        createConfig(config)
          ..method = 'put'
          ..url = url,
      );

  Future<Response> patch(url, [AjanuwHttpConfig? config]) => request(
        createConfig(config)
          ..method = 'patch'
          ..url = url,
      );

  Future<StreamedResponse> patchStream(url, [AjanuwHttpConfig? config]) =>
      requestStream(
        createConfig(config)
          ..method = 'patch'
          ..url = url,
      );

  Future<Response> delete(url, [AjanuwHttpConfig? config]) => request(
        createConfig(config)
          ..method = 'delete'
          ..url = url,
      );

  Future<StreamedResponse> deleteStream(url, [AjanuwHttpConfig? config]) =>
      requestStream(
        createConfig(config)
          ..method = 'delete'
          ..url = url,
      );

  Future<String> read(url, [AjanuwHttpConfig? config]) async {
    final response = await get(
        url, createConfig(config)..responseType = ResponseType.Response);
    return response.body;
  }

  Future<Uint8List> readBytes(url, [AjanuwHttpConfig? config]) async {
    final response = await get(
        url, createConfig(config)..responseType = ResponseType.Response);
    return response.bodyBytes;
  }
}
