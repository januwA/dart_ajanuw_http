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
  });
}
