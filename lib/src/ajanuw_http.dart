import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart';
import '../ajanuw_http.dart';
import 'ajanuw_http_config.dart';
import 'util/util.dart';

Future<Response> ajanuwHttp(
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
  var completer = Completer<Uint8List>();
  stream.stream.listen(
    cfg.onDownloadProgress == null
        ? (List<int> d) => bytes.addAll(d)
        : (List<int> d) {
            bytes.addAll(d);
            cfg.onDownloadProgress(bytes.length, stream.contentLength);
          },
    onDone: () => completer.complete(Uint8List.fromList(bytes)),
  );

  // 获取response
  var res = Response.bytes(
    await completer.future,
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
      res = await it.response(res);
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
