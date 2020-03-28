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
    dynamic url, Map<String, dynamic /*String|Iterable<String>*/ > params) {
  if (url is String) {
    url = Uri.parse(url);
  }
  if (params != null) {
    try {
      assert(url is Uri);
      url = url.replace(
        queryParameters: Map<String, dynamic>.from({
          ...url.queryParametersAll,
          ...params,
        }),
      );
    } catch (e) {
      rethrow;
    }
  }
  return url;
}
