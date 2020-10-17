import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart';

class HeaderInterceptor extends AjanuwHttpInterceptors {
  @override
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config) async {
    print(config.headers); // {x-b: b, x-a: a}
    return config;
  }

  @override
  Future<BaseResponse> response(BaseResponse response, _) async {
    return response;
  }
}

void main() async {
  var api = AjanuwHttp()
    ..config.baseURL = 'http://localhost:3000/api/'
    ..config.headers = {'x-a': 'a'}
    ..interceptors.add(HeaderInterceptor());

  var r = await api.get('/cats', AjanuwHttpConfig(headers: {'x-b': 'b'}));
  print(r.body);
}
