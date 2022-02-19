import 'package:ajanuw_http/ajanuw_http.dart';

class HeaderInterceptor extends AjanuwHttpInterceptors {
  @override
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config) async {
    config.headers!.addAll({'x-senduser': 'ajanuw'});
    return config;
  }

  @override
  Future<BaseResponse> response(BaseResponse response, _) async {
    return response;
  }
}

class HeaderInterceptor2 extends AjanuwHttpInterceptors {
  @override
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config) async {
    config.headers!.addAll({'x-url': config.url.toString()});
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
    ..interceptors.add(HeaderInterceptor());

  var r = await api.get(
    '/',
    AjanuwHttpConfig(
      params: {'message': 'test interceptors'},
      interceptors: [HeaderInterceptor2()],
    ),
  );
  print(r.request?.headers);
  print(r.body);

  // get 2
  print('==============================================');
  r = await api.get('/');
  print(r.request?.headers);
  print(r.body);
}
