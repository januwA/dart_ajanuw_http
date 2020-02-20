import 'dart:async';

import 'package:http/http.dart' show MultipartRequest, ByteStream;

class MR extends MultipartRequest {
  Function(int bytes, int total) onUploadProgress;
  MR(String method, Uri url, {this.onUploadProgress}) : super(method, url);

  /// 重写这个方法
  @override
  ByteStream finalize() {
    final byteStream = super.finalize();
    if (onUploadProgress == null) return byteStream;
    final total = contentLength;
    var bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        sink.add(data);
        bytes += data.length;
        onUploadProgress(bytes, total);
      },
    );
    final stream = byteStream.transform(t);
    return ByteStream(stream);
  }
}
