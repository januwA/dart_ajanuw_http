import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('toHref Method Test', () {
      final r = 'http://localhost:3000/api/list';
      
      AjanuwHttp.basePath = 'http://localhost:3000/api';
      expect(AjanuwHttp.toHref('/list'), r);
      
      AjanuwHttp.basePath = 'http://localhost:3000/api/';
      expect(AjanuwHttp.toHref('/list'), r);
      
      AjanuwHttp.basePath = 'http://localhost:3000/api/';
      expect(AjanuwHttp.toHref('list'), r);

      AjanuwHttp.basePath = 'http://localhost:3000/api';
      expect(AjanuwHttp.toHref('list'), r);
    });
  });
}
