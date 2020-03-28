import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import '../ajanuw_http.dart';
import 'util/m_r.dart';
import 'util/merge_params.dart';

BaseRequest _createRequest(AjanuwHttpConfig cfg) {
  var req;
  if (cfg.files == null) {
    req = Request(cfg.method, cfg.url);
    if (cfg.body != null) {
      if (cfg.body is String) {
        req.body = cfg.body;
      } else if (cfg.body is List) {
        req.bodyBytes = cfg.body.cast<int>();
      } else if (cfg.body is Map) {
        req.bodyFields = cfg.body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "${cfg.body}".');
      }
    }
  } else {
    req = MR(cfg.method, cfg.url, onUploadProgress: cfg.onUploadProgress);
    if (cfg.body != null) req.fields.addAll(cfg.body);
    if (cfg.files != null) req.files.addAll(cfg.files);
  }
  if (cfg.headers != null) req.headers.addAll(cfg.headers);
  if (cfg.encoding != null) req.encoding = cfg.encoding;

  return req;
}

class AjanuwHttpConfig {
  dynamic url /* String|Uri */;
  String method;
  dynamic /* String|List<int>|Map<String, String> */ body;
  Map<String, dynamic /*String|Iterable<String>*/ > params;
  Map<String, String> headers;
  Duration timeout;
  Encoding encoding;

  /// 请求返回时的进度
  AjanuwHttpProgress onProgress;

  /// 上传文件时，监听进度
  AjanuwHttpProgress onUploadProgress;

  /// 文件列表
  List<MultipartFile> files;
  AjanuwHttpConfig({
    this.url,
    this.method = 'get',
    this.body,
    this.params,
    this.headers,
    this.timeout,
    this.encoding,
    this.onUploadProgress,
    this.onProgress,
    this.files,
  });
}

Future<Response> ajanuwHttp(AjanuwHttpConfig cfg) async {
  var f = Completer<Response>();
  cfg.url = mergeParams(cfg.url, cfg.params);
  assert(cfg.url is Uri);

  // 1. 创建request
  var req = _createRequest(cfg);

  // 2. 发送
  var client = Client();
  var stream = cfg.timeout == null
      ? await client.send(req)
      : await client.send(req).timeout(cfg.timeout);

  var bytes = <int>[];
  var completer = Completer<Uint8List>();
  stream.stream.listen(
    cfg.onProgress == null
        ? (List<int> d) => bytes.addAll(d)
        : (List<int> d) {
            bytes.addAll(d);
            cfg.onProgress(bytes.length, stream.contentLength);
          },
    onDone: () => completer.complete(Uint8List.fromList(bytes)),
  );

  // 3. 获取response
  var res = Response.bytes(
    await completer.future,
    stream.statusCode,
    request: stream.request,
    headers: stream.headers,
    isRedirect: stream.isRedirect,
    persistentConnection: stream.persistentConnection,
    reasonPhrase: stream.reasonPhrase,
  );

  f.complete(res);

  client.close();
  return f.future;
}
