import 'dart:convert';

import 'package:http/http.dart';

import '../ajanuw_http.dart';

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
  });

  /// 将另一个config[other]合并到当前的config
  /// 如果当前config的某项配置不存在，就获取[other]里面的值
  AjanuwHttpConfig merge(AjanuwHttpConfig other) {
    var r = AjanuwHttpConfig(
      url: url ?? other.url,
      method: method ?? other.method,
      body: body ?? other.body,
      params: params ?? other.params,
      headers: headers,
      timeout: timeout ?? other.timeout,
      encoding: encoding ?? other.encoding,
      onUploadProgress: onUploadProgress ?? other.onUploadProgress,
      onDownloadProgress: onDownloadProgress ?? other.onDownloadProgress,
      files: files ?? other.files,
      validateStatus: validateStatus ?? other.validateStatus,
      paramsSerializer: paramsSerializer ?? other.paramsSerializer,
      baseURL: baseURL ?? other.baseURL,
    );

    if (other.headers != null) {
      other.headers.forEach((key, value) {
        if (r.headers[key] == null) {
          r.headers[key] = value;
        }
      });
    }

    return r;
  }
}
