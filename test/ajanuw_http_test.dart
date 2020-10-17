import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:ajanuw_http/src/util/util.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('mergeUrl Method Test', () {
      expect(mergeUrl('http://localhost:3000', '/api/cats'),
          'http://localhost:3000/api/cats');
      expect(mergeUrl('http://localhost:3000/api', '/cats'),
          'http://localhost:3000/api/cats');
      expect(mergeUrl('http://localhost:3000/api/', '/cats'),
          'http://localhost:3000/api/cats');
      expect(mergeUrl('http://localhost:3000/api', 'cats'),
          'http://localhost:3000/api/cats');
    });

    test('config merge test', () {
      var c1 = AjanuwHttpConfig(
        baseURL: 'http://localhost:3000',
        method: 'POST',
        headers: {'x-a': '1'},
        params: {'name': 'ajanuw', 'token': '123'},
      );
      var c2 = AjanuwHttpConfig(
        method: 'GET',
        url: '/cats',
        headers: {'x-a': '2', 'x-b': '1'},
        params: {'name': 'suou', 'age': '12'},
      );
      var c3 = c1.merge(c2);

      expect(c3.method, 'POST');
      expect(c2.method, 'GET');
      expect(c1.method, 'POST');

      expect(c3.baseURL, 'http://localhost:3000');
      expect(c2.baseURL, null);

      expect(c3.url, '/cats');
      expect(c1.url, null);

      expect(c3.headers['x-a'], '1');
      expect(c3.headers['x-b'], '1');

      expect(c3.params['name'], 'ajanuw');
      expect(c3.params['age'], '12');
      expect(c3.params['token'], '123');

    });
  });
}
