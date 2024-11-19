import 'dart:convert';

import 'package:alice_interceptor/core/alice_core.dart';
import 'package:alice_interceptor/model/alice_http_call.dart';
import 'package:alice_interceptor/model/alice_http_request.dart';
import 'package:alice_interceptor/model/alice_http_response.dart';
import 'package:dio/dio.dart' as dio;
class AliceHttpAdapter {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates alice http adapter
  AliceHttpAdapter(this.aliceCore);

  /// Handles http response. It creates both request and response from http call
  void onResponse(dio.Response response, {dynamic body}) {
    
    final request = response.requestOptions;

    final AliceHttpCall call = AliceHttpCall(response.requestOptions.hashCode);
    call.loading = true;
    call.client = "HttpClient (http package)";
    call.uri = request.uri.toString();
    call.method = request.method;
    var path = request.path;
    if (path.isEmpty) {
      path = "/";
    }
    call.endpoint = path;

    call.server = request.uri.host;
    if (request.uri.scheme == "https") {
      call.secure = true;
    }

    final AliceHttpRequest httpRequest = AliceHttpRequest();

    // we are guaranteed` the existence of body and headers
    if (body != null) {
      httpRequest.body = body;
    }
    // ignore: cast_nullable_to_non_nullable
    httpRequest.body = body ?? (response.requestOptions).data ?? "";
    httpRequest.size = utf8.encode(httpRequest.body.toString()).length;
    httpRequest.headers = response.requestOptions.headers;
  
    httpRequest.time = DateTime.now();

    String? contentType = "unknown";
    if (httpRequest.headers.containsKey("Content-Type")) {
      contentType = httpRequest.headers["Content-Type"] as String?;
    }

    httpRequest.contentType = contentType;

    httpRequest.queryParameters = response.requestOptions.uri.queryParameters;

    final AliceHttpResponse httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode;
    httpResponse.body = response.data;

    httpResponse.size = utf8.encode(response.data.toString()).length;
    httpResponse.time = DateTime.now();
    final Map<String, String> responseHeaders = {};
    response.headers.forEach((header, values) {
      responseHeaders[header] = values.toString();
    });
    httpResponse.headers = responseHeaders;

    call.request = httpRequest;
    call.response = httpResponse;

    call.loading = false;
    call.duration = httpResponse.time.millisecondsSinceEpoch -
        httpRequest.time.millisecondsSinceEpoch;
    aliceCore.addCall(call);
  }
}
