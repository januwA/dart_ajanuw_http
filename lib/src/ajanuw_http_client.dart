import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

class AjanuwHttpClient implements Client {
  final Client _client = Client();

  bool isClosed = false;

  @override
  void close() {
    if (!isClosed) {
      isClosed = true;
      _client.close();
    }
  }

  @override
  Future<Response> delete(url, {Map<String, String> headers}) =>
      _client.delete(url, headers: headers);

  @override
  Future<Response> get(url, {Map<String, String> headers}) =>
      _client.get(url, headers: headers);

  @override
  Future<Response> head(url, {Map<String, String> headers}) =>
      _client.head(url, headers: headers);

  @override
  Future<Response> patch(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _client.patch(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> post(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _client.post(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> put(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _client.put(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<String> read(url, {Map<String, String> headers}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(url, {Map<String, String> headers}) =>
      _client.readBytes(url, headers: headers);

  /// 数据接收完后将自动调用[close]，所以这个client只能使用一次
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    assert(isClosed == false);
    var r = await _client.send(request);
    var data$ = StreamController<List<int>>();
    r.stream.listen(
      (value) => data$.sink.add(value),
      onDone: () {
        data$.close();
        close();
      },
      onError: (e) => data$.addError(e),
    );
    return StreamedResponse(
      data$.stream.asBroadcastStream(),
      r.statusCode,
      contentLength: r.contentLength,
      request: r.request,
      headers: r.headers,
      isRedirect: r.isRedirect,
      persistentConnection: r.persistentConnection,
      reasonPhrase: r.reasonPhrase,
    );
  }
}
