import 'package:ajanuw_http/ajanuw_http.dart';
import 'package:http/http.dart';

class HeaderInterceptor extends AjanuwHttpInterceptors {
  @override
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config) async {
    if (config.method.toLowerCase() == 'post' && config.body is Map) {
      (config.body as Map)['x-key'] = '拦截器数据';
    }
    return config;
  }

  @override
  Future<Response> response(BaseResponse response, _) async {
    return response;
  }
}

void main() async {
  var api = AjanuwHttp()
    ..config.baseURL = 'http://localhost:3000/api/'
    ..interceptors.add(HeaderInterceptor());

  var r = await api.post('/cats', AjanuwHttpConfig(body: {'name': 'ajanuw'}));

  print(r.body);
}
