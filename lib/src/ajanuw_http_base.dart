import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import 'util/m_r.dart';
import 'util/merge_params.dart';

typedef AjanuwHttpProgress = Function(int bytes, int total);

/// 拦截器基类
abstract class AjanuwHttpInterceptors {
  Future<Request> request(BaseRequest request);

  Future<Response> response(BaseResponse response);
}

class AjanuwHttp extends BaseClient {
  static String basePath;
  static Duration timeout;

  /// 所有拦截器
  static List<AjanuwHttpInterceptors> interceptors = [];

  /// 将[url]拼接到[basePath]
  static String toHref(String url) {
    if (basePath == null) return url;
    return basePath.replaceAll(RegExp(r'\/?$'), '') +
        '/' +
        url.replaceAll(RegExp(r'^\/?'), '');
  }

  final Client _client = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) => _client.send(request);

  @override
  Future<Response> head(
    url, {
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) =>
      _sendUnstreamed(
        method: 'HEAD',
        params: params,
        url: url,
        headers: headers,
        onProgress: onProgress,
      );

  @override
  Future<Response> get(
    url, {
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) {
    return _sendUnstreamed(
      method: 'GET',
      url: url,
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
  }

  @override
  Future<Response> post(
    url, {
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) =>
      _sendUnstreamed(
        method: 'POST',
        url: url,
        headers: headers,
        body: body,
        params: params,
        encoding: encoding,
        onProgress: onProgress,
      );

  @override
  Future<Response> put(
    url, {
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) =>
      _sendUnstreamed(
        method: 'PUT',
        url: url,
        params: params,
        headers: headers,
        body: body,
        encoding: encoding,
        onProgress: onProgress,
      );

  @override
  Future<Response> patch(
    url, {
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) =>
      _sendUnstreamed(
        method: 'PATCH',
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
        onProgress: onProgress,
      );

  @override
  Future<Response> delete(
    url, {
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) =>
      _sendUnstreamed(
        method: 'DELETE',
        url: url,
        params: params,
        headers: headers,
        onProgress: onProgress,
      );

  /// 来自[base_client]
  Uri _fromUriOrString(uri) => uri is String ? Uri.parse(uri) : uri as Uri;

  /// 来自[base_client]
  void _checkResponseSuccess(url, Response response) {
    if (response.statusCode < 400) return;
    var message = 'Request to $url failed with status ${response.statusCode}';
    if (response.reasonPhrase != null) {
      message = '$message: ${response.reasonPhrase}';
    }
    throw ClientException('$message.', _fromUriOrString(url));
  }

  @override
  Future<String> read(
    url, {
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) async {
    final response = await get(
      url,
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
    _checkResponseSuccess(url, response);
    return response.body;
  }

  @override
  Future<Uint8List> readBytes(
    url, {
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    Map<String, String> headers,
    AjanuwHttpProgress onProgress,
  }) async {
    final response = await get(
      url,
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
    _checkResponseSuccess(url, response);
    return response.bodyBytes;
  }

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
  Future<Response> postFile(
    url, {
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    Map<String, String> headers,
    Map<String, String> body,
    List<MultipartFile> files,
    AjanuwHttpProgress onUploadProgress,
    AjanuwHttpProgress onProgress,
  }) =>
      _sendUnstreamed(
        method: 'POST',
        url: url,
        params: params,
        headers: headers,
        body: body,
        files: files,
        onUploadProgress: onUploadProgress,
        onProgress: onProgress,
      );

  Future<Response> _sendUnstreamed({
    String method,
    dynamic /* Uri|String */ url,
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic body,
    Encoding encoding,
    List<MultipartFile> files,
    AjanuwHttpProgress onUploadProgress,
    AjanuwHttpProgress onProgress,
  }) async {
    var paramUrl = url is Uri ? url : Uri.parse(url);
    var request = _createRequest(
      method: method,
      url: mergeParams(paramUrl, params),
      headers: headers,
      params: params,
      body: body,
      encoding: encoding,
      files: files,
      onUploadProgress: onUploadProgress,
    );

    // 运行request拦截器
    for (var it in interceptors) {
      request = await it.request(request);
    }

    var stream = timeout == null
        ? await send(request)
        : await send(request).timeout(timeout);

    var bytes = <int>[];
    var completer = Completer<Uint8List>();
    stream.stream.listen(
      onProgress == null
          ? (List<int> d) => bytes.addAll(d)
          : (List<int> d) {
              bytes.addAll(d);
              onProgress(bytes.length, stream.contentLength);
            },
      onDone: () => completer.complete(Uint8List.fromList(bytes)),
    );

    var response = Response.bytes(
      await completer.future,
      stream.statusCode,
      request: stream.request,
      headers: stream.headers,
      isRedirect: stream.isRedirect,
      persistentConnection: stream.persistentConnection,
      reasonPhrase: stream.reasonPhrase,
    );

    // 运行response拦截器
    for (var it in interceptors) {
      response = await it.response(response);
    }

    return response;
  }

  BaseRequest _createRequest({
    String method,
    Uri url,
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic body,
    Encoding encoding,
    List<MultipartFile> files,
    Function(int bytes, int total) onUploadProgress,
  }) {
    /// 这里稍微智能判断下，如果有[scheme]，那么就不拼接[basePath]
    /// 避免不必要的麻烦
    if (!url.hasScheme) {
      url = Uri.parse(toHref(url.toString()));
    }
    var request;
    if (files == null) {
      request = Request(method, url);
      if (headers != null) request.headers.addAll(headers);
      if (encoding != null) request.encoding = encoding;
      if (body != null) {
        if (body is String) {
          request.body = body;
        } else if (body is List) {
          request.bodyBytes = body.cast<int>();
        } else if (body is Map) {
          request.bodyFields = body.cast<String, String>();
        } else {
          throw ArgumentError('Invalid request body "$body".');
        }
      }
    } else {
      request = MR(method, url, onUploadProgress: onUploadProgress);
      if (headers != null) request.headers.addAll(headers);
      if (body != null) request.fields.addAll(body);
      if (files != null) request.files.addAll(files);
    }
    return request;
  }

  void dispose() {
    _client?.close();
  }
}

extension AjanuwHttpStringExtensions on String {
  Future<Response> head({
    Map<String, String> headers,
    Map<String, dynamic> params,
    dynamic Function(int, int) onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.head(
      this,
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }

  Future<Response> get({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.get(
      this,
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }

  Future<Response> post({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.post(
      this,
      headers: headers,
      params: params,
      body: body,
      encoding: encoding,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }

  Future<Response> put({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.put(
      this,
      headers: headers,
      params: params,
      body: body,
      encoding: encoding,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }

  Future<Response> patch({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.patch(
      this,
      headers: headers,
      params: params,
      body: body,
      encoding: encoding,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }

  Future<Response> delete({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.delete(
      this,
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }

  Future<String> read({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.read(
      this,
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }

  Future<Uint8List> readBytes({
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    Map<String, String> headers,
    AjanuwHttpProgress onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.readBytes(
      this,
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }

  Future<Response> postFile({
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    Map<String, String> headers,
    Map<String, String> body,
    List<MultipartFile> files,
    AjanuwHttpProgress onUploadProgress,
    AjanuwHttpProgress onProgress,
  }) async {
    final http = AjanuwHttp();
    var r = await http.postFile(
      this,
      headers: headers,
      params: params,
      body: body,
      files: files,
      onUploadProgress: onUploadProgress,
      onProgress: onProgress,
    );
    http.dispose();
    return r;
  }
}

extension AjanuwHttpUriExtensions on Uri {
  Future<Response> head({
    Map<String, String> headers,
    Map<String, dynamic> params,
    dynamic Function(int, int) onProgress,
  }) {
    return toString().head(
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
  }

  Future<Response> get({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) {
    return toString().get(
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
  }

  Future<Response> post({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) {
    return toString().post(
      headers: headers,
      params: params,
      body: body,
      encoding: encoding,
      onProgress: onProgress,
    );
  }

  Future<Response> put({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) {
    return toString().put(
      headers: headers,
      params: params,
      body: body,
      encoding: encoding,
      onProgress: onProgress,
    );
  }

  Future<Response> patch({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic /* String|List<int>|Map<String, String> */ body,
    Encoding encoding,
    AjanuwHttpProgress onProgress,
  }) {
    return toString().patch(
      headers: headers,
      params: params,
      body: body,
      encoding: encoding,
      onProgress: onProgress,
    );
  }

  Future<Response> delete({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) {
    return toString().delete(
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
  }

  Future<String> read({
    Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    AjanuwHttpProgress onProgress,
  }) {
    return toString().read(
      headers: headers,
      params: params,
      onProgress: onProgress,
    );
  }

  Future<Uint8List> readBytes({
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    Map<String, String> headers,
    AjanuwHttpProgress onProgress,
  }) {
    return toString().readBytes(
      params: params,
      headers: headers,
      onProgress: onProgress,
    );
  }

  Future<Response> postFile({
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    Map<String, String> headers,
    Map<String, String> body,
    List<MultipartFile> files,
    AjanuwHttpProgress onUploadProgress,
    AjanuwHttpProgress onProgress,
  }) {
    return toString().postFile(
      params: params,
      headers: headers,
      body: body,
      files: files,
      onProgress: onProgress,
      onUploadProgress: onUploadProgress,
    );
  }
}
