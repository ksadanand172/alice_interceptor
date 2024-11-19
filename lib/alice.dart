import 'package:alice_interceptor/core/alice_core.dart';
import 'package:alice_interceptor/core/alice_dio_interceptor.dart';
import 'package:alice_interceptor/core/alice_http_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Alice {
  final bool showNotification = true;
  final bool darkTheme = false;
  final String notificationIcon = "@mipmap/ic_launcher";
  final int maxCallsCount = 1000;
  GlobalKey<NavigatorState>? _navigatorKey;
  late AliceCore _aliceCore;
  late AliceHttpAdapter _httpAdapter;

  /// Creates dev_interceptor instance.
  Alice._({
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
    _aliceCore = AliceCore(
      _navigatorKey,
      // showNotification: showNotification,
      darkTheme: darkTheme,
      // notificationIcon: notificationIcon,
      maxCallsCount: maxCallsCount,
    );
    _httpAdapter = AliceHttpAdapter(_aliceCore);
  }

  static final Alice instance = Alice._();

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    debugPrint("AliceCore-navigatorKey has been set.");
    _navigatorKey = navigatorKey;
    _aliceCore.navigatorKey = navigatorKey;
  }

  /// Get Dio interceptor which should be applied to Dio instance.
  AliceDioInterceptor getDioInterceptor() {
    return AliceDioInterceptor(_aliceCore);
  }

  /// Handle both request and response from http package
  void onHttpResponse(Response response, {dynamic body}) {
    _httpAdapter.onResponse(response, body: body);
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void showInspector() {
    _aliceCore.navigateToCallListScreen();
  }
}
