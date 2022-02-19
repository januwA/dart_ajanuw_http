import '../../ajanuw_http.dart';
import 'm_r.dart';

AjanuwHttpConfig createConfig(AjanuwHttpConfig? config) {
  if (config != null) return config;
  return AjanuwHttpConfig();
}

/// 将[baseURL]于[url]合并
///
/// ```dart
///
/// // http://localhost:3000//api/list
/// mergeUrl('http://localhost:3000', '/api/list');
/// ```
String mergeUrl(String baseURL, String? url) {
  assert(url is String);
  return url != null
      ? baseURL.replaceAll(RegExp(r'\/+$'), '') +
          '/' +
          url.replaceAll(RegExp(r'^\/+'), '')
      : baseURL;
}

/// Merge params into url
///
/// ```dart
/// var url = Uri.parse('http://example.com/xx?page=1&page=2&foo=bar');
/// Map<String, dynamic> params = {
///   'name': 'a',
///   'data': ['x', 'y'],
///   'foo': 'z'
/// };
/// var newUrl = mergeParams(url, params); // http://example.com/xx?page=1&page=2&foo=z&name=a&data=x&data=y
/// ```
Uri mergeParams(
  dynamic url,
  Map<String, dynamic /*String|Iterable<String>*/ >? params, [
  String Function(Map<String, dynamic>)? paramsSerializer,
]) {
  if (url is String) url = Uri.parse(url);

  assert(url is Uri);

  // 提供了验证器
  if (paramsSerializer != null) {
    var oldParams = Uri.parse(url.toString()).queryParametersAll;
    var query = paramsSerializer(params!);

    // 将验证器返回的params字符串拼接到[url]
    url = url.replace(query: query);
    url = url.replace(
      queryParameters: Map<String, dynamic>.from({
        ...oldParams,
        ...url.queryParametersAll,
      }),
    );
    url = (url as Uri).replace(query: Uri.decodeComponent(url.query));
    return url;
  }

  if (params != null && params.isNotEmpty) {
    url = url.replace(
      // queryParameters会执行encodeComponent，所以记得decodeComponent
      // 不然会让用户的数据出现错误
      // queryParametersAll会执行decodeComponent
      queryParameters: Map<String, dynamic>.from({
        ...url.queryParametersAll,
        ...params,
      }),
    );
    url = (url as Uri).replace(query: Uri.decodeComponent(url.query));
  }
  return url;
}

BaseRequest createRequest(AjanuwHttpConfig cfg) {
  var req;
  if (cfg.files?.isEmpty ?? true) {
    req = Request(cfg.method!, cfg.url);
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
    req = MR(cfg.method!, cfg.url, onUploadProgress: cfg.onUploadProgress);
    if (cfg.body != null) req.fields.addAll(cfg.body);
    if (cfg.files != null) req.files.addAll(cfg.files);
  }
  if (cfg.headers != null) req.headers.addAll(cfg.headers);
  if (cfg.encoding != null) req.encoding = cfg.encoding;

  return req;
}

AjanuwHttpConfig handleConfig(AjanuwHttpConfig config) {
  // 拼接baseurl和url
  if (config.baseURL != null && !Uri.parse(config.url.toString()).hasScheme) {
    config.url = mergeUrl(config.baseURL!, config.url.toString());
  }

  // 拼接params
  config.url = mergeParams(config.url, config.params, config.paramsSerializer);
  return config;
}
