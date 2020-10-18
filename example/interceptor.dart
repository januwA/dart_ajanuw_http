import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart';

class HeaderInterceptor extends AjanuwHttpInterceptors {
  @override
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config) async {
    config.headers ??= {};

    if (config.method.toLowerCase() == 'post' && config.body is Map) {
      (config.body as Map)['x-key'] = 'key';
    }

    config.headers.addAll({'x-senduser': 'ajanuw'});
    return config;
  }

  @override
  Future<BaseResponse> response(BaseResponse response, _) async {
    print('response.');
    return response;
  }
}

void main() async {
  var api = AjanuwHttp()
    ..config.baseURL = 'http://localhost:3000/api/'
    ..interceptors.add(HeaderInterceptor());

  var r = await api.get('/');
  print(r.request.headers);
  print(r.body);
}
