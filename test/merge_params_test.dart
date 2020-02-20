import 'package:ajanuw_http/src/util/merge_params.dart';
import 'package:test/test.dart';

void main() {
  test('test merge params', () {
    var url = Uri.parse('http://example.com/xx?page=1&page=2&foo=bar');
    var params = {
      'name': 'a',
      'data': ['x', 'y'],
      'foo': 'z'
    };
    var newUrl = mergeParams(url, params);
    expect(newUrl.queryParametersAll['data'] != null, true);
    expect(newUrl.queryParametersAll['foo'] != null, true);
    expect(newUrl.queryParametersAll['foo'], ['z']);
  });
}
