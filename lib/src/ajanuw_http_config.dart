import 'dart:convert';

import 'package:http/http.dart';

enum HttpFutureType {
  Response,
  StreamedResponse,
}

typedef AjanuwHttpProgress = Function(int bytes, int total);

class AjanuwHttpConfig {
  /// String|Uri
  dynamic url;

  /// 请求方法
  String method;

  /// String|List<int>|Map<String, String>
  dynamic body;
  Map<String, dynamic /*String|Iterable<String>*/ > params;
  Map<String, String> headers;
  Duration timeout;
  Encoding encoding;

  /// 监听下载文件进度
  ///
  /// - 如果[httpFutureType]设置为[HttpFutureType.StreamedResponse]那个此函数将不会调用
  AjanuwHttpProgress onDownloadProgress;

  /// 监听上传文件进度
  AjanuwHttpProgress onUploadProgress;

  /// 文件列表
  List<MultipartFile> files;

  /// 允许自定义合法状态码范围
  bool Function(int status) validateStatus;

  /// 自定义params的解析函数
  String Function(Map<String, dynamic> params) paramsSerializer;

  /// 默认地址
  String baseURL;

  /// 默认返回[Response]，但是也可以返回[StreamedResponse]
  HttpFutureType httpFutureType;

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
    this.httpFutureType,
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
      httpFutureType: httpFutureType ?? other.httpFutureType,
    );

    if (other.params != null) {
      r.params ??= {};
      other.params.forEach((key, value) => r.params[key] ??= value);
    }

    if (other.headers != null) {
      r.headers ??= {};
      other.headers.forEach((key, value) => r.headers[key] ??= value);
    }

    if (other.files != null) {
      r.files ??= [];
      r.files.addAll(other.files);
    }

    return r;
  }
}
