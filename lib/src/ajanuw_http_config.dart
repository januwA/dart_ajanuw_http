import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

enum ResponseType {
  Response,
  StreamedResponse,
}

typedef AjanuwHttpProgress = Function(int bytes, int total);

/// 拦截器基类
abstract class AjanuwHttpInterceptors {
  Future<AjanuwHttpConfig> request(AjanuwHttpConfig config);

  Future<BaseResponse> response(BaseResponse response, AjanuwHttpConfig config);
}

class AjanuwHttpConfig {
  /// String|Uri
  dynamic url;

  /// 请求方法
  String? method;

  /// String|List<int>|Map<String, String>
  dynamic body;
  Map<String, dynamic /*String|Iterable<String>*/ >? params;
  Map<String, String>? headers;
  Duration? timeout;
  Encoding? encoding;

  /// 监听下载文件进度
  AjanuwHttpProgress? onDownloadProgress;

  /// 监听上传文件进度
  AjanuwHttpProgress? onUploadProgress;

  /// 文件列表
  List<MultipartFile>? files;

  /// 允许自定义合法状态码范围
  bool Function(int status)? validateStatus;

  /// 自定义params的解析函数
  String Function(Map<String, dynamic> params)? paramsSerializer;

  /// 默认地址
  String? baseURL;

  /// 默认返回[Response]，但是也可以返回[StreamedResponse]
  ResponseType? responseType;

  /// 关闭 client，将调用`client.close()`
  Completer? close;

  /// 作用于当前请求的拦截器，调用顺序优先于全局的拦截器
  List<AjanuwHttpInterceptors?>? interceptors = [];

  AjanuwHttpConfig({
    this.url,
    this.method,
    this.body,
    this.params,
    this.headers,
    this.timeout,
    this.encoding,
    this.onUploadProgress,
    this.onDownloadProgress,
    this.files,
    this.validateStatus,
    this.paramsSerializer,
    this.baseURL,
    this.responseType,
    this.close,
    this.interceptors,
  });

  /// 如果当前config的某项为null，则获取[other]里面的值, 并返回一个新的config
  ///
  /// - params 合并
  /// - header 合并
  /// - files 合并
  AjanuwHttpConfig merge(AjanuwHttpConfig other) {
    var r = AjanuwHttpConfig(
      url: url ?? other.url,
      method: method ?? other.method,
      body: body ?? other.body,
      params: params,
      headers: headers,
      timeout: timeout ?? other.timeout,
      encoding: encoding ?? other.encoding,
      onUploadProgress: onUploadProgress ?? other.onUploadProgress,
      onDownloadProgress: onDownloadProgress ?? other.onDownloadProgress,
      files: files,
      validateStatus: validateStatus ?? other.validateStatus,
      paramsSerializer: paramsSerializer ?? other.paramsSerializer,
      baseURL: baseURL ?? other.baseURL,
      responseType: responseType ?? other.responseType,
      close: close ?? other.close,
      interceptors: interceptors,
    );

    r.params ??= {};
    if (other.params?.isNotEmpty ?? false) {
      other.params!.forEach((key, value) => r.params![key] ??= value);
    }

    r.headers ??= {};
    if (other.headers?.isNotEmpty ?? false) {
      other.headers!.forEach((key, value) => r.headers![key] ??= value);
    }

    r.files ??= [];
    if (other.files?.isNotEmpty ?? false) {
      r.files!.addAll(other.files!);
    }

    r.interceptors ??= [];
    if (other.interceptors?.isNotEmpty ?? false) {
      r.interceptors!.addAll(other.interceptors!);
    }

    return r;
  }
}
