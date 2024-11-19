import 'dart:async';

import 'package:alice_interceptor/core/alice_utils.dart';
import 'package:alice_interceptor/model/alice_http_call.dart';
import 'package:alice_interceptor/model/alice_http_error.dart';
import 'package:alice_interceptor/model/alice_http_response.dart';
import 'package:alice_interceptor/ui/page/alice_calls_list_screen.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class AliceCore {
  // final bool showNotification;
  final bool darkTheme;
  final BehaviorSubject<List<AliceHttpCall>> callsSubject =
      BehaviorSubject.seeded([]);
  // final String notificationIcon;
  final int maxCallsCount;

  // late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  GlobalKey<NavigatorState>? navigatorKey;
  Brightness _brightness = Brightness.light;
  StreamSubscription? _callsSubscription;
  // String? _notificationMessage;
  // String? _notificationMessageShown;
  // bool _notificationProcessing = false;

  /// Creates dev_interceptor core instance
  AliceCore(
    this.navigatorKey, {
    // required this.showNotification,
    required this.darkTheme,
    // required this.notificationIcon,
    required this.maxCallsCount,
  }) {
      // _initializeNotificationsPlugin();
      // _callsSubscription = callsSubject.listen((_) => _onCallsChanged());

    _brightness = darkTheme ? Brightness.dark : Brightness.light;
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    _callsSubscription?.cancel();
  }

  /// Get currently used brightness
  Brightness get brightness => _brightness;

  // void _initializeNotificationsPlugin() {
  //   _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   final initializationSettingsAndroid =
  //       AndroidInitializationSettings(notificationIcon);
  //   const initializationSettingsIOS = IOSInitializationSettings(requestAlertPermission: false);
  //   final initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsIOS,
  //   );
  //   _flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //     onSelectNotification: _onDidReceiveNotificationResponse,
  //   );
  // }

  // void _onCallsChanged() async {
  //   if (callsSubject.value.isNotEmpty) {
  //     _notificationMessage = _getNotificationMessage();
  //     if (_notificationMessage != _notificationMessageShown &&
  //         !_notificationProcessing) {
  //       await _showLocalNotification();
  //       _onCallsChanged();
  //     }
  //   }
  // }

  // Future<void> _onDidReceiveNotificationResponse(
  //     String? payload) async {
  //   assert(payload != null, "payload can't be null");
  //   navigateToCallListScreen();
  //   return;
  // }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void navigateToCallListScreen() {
    final context = getContext();
    if (context == null) {
      AliceUtils.log(
        "Cant start Alice HTTP Inspector. Please add NavigatorKey to your application",
      );
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/api_inspector"),
        builder: (context) => AliceCallsListScreen(this),
      ),
    );
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() => navigatorKey?.currentState?.overlay?.context;

  // String _getNotificationMessage() {
  //   final List<AliceHttpCall> calls = callsSubject.value;
  //   final int successCalls = calls
  //       .where(
  //         (call) =>
  //             call.response != null &&
  //             call.response!.status! >= 200 &&
  //             call.response!.status! < 300,
  //       )
  //       .toList()
  //       .length;
  //
  //   final int redirectCalls = calls
  //       .where(
  //         (call) =>
  //             call.response != null &&
  //             call.response!.status! >= 300 &&
  //             call.response!.status! < 400,
  //       )
  //       .toList()
  //       .length;
  //
  //   final int errorCalls = calls
  //       .where(
  //         (call) =>
  //             call.response != null &&
  //             call.response!.status! >= 400 &&
  //             call.response!.status! < 600,
  //       )
  //       .toList()
  //       .length;
  //
  //   final int loadingCalls =
  //       calls.where((call) => call.loading).toList().length;
  //
  //   final StringBuffer notificationsMessage = StringBuffer();
  //   if (loadingCalls > 0) {
  //     notificationsMessage.write("Loading: $loadingCalls");
  //     notificationsMessage.write(" | ");
  //   }
  //   if (successCalls > 0) {
  //     notificationsMessage.write("Success: $successCalls");
  //     notificationsMessage.write(" | ");
  //   }
  //   if (redirectCalls > 0) {
  //     notificationsMessage.write("Redirect: $redirectCalls");
  //     notificationsMessage.write(" | ");
  //   }
  //   if (errorCalls > 0) {
  //     notificationsMessage.write("Error: $errorCalls");
  //   }
  //   String notificationMessageString = notificationsMessage.toString();
  //   if (notificationMessageString.endsWith(" | ")) {
  //     notificationMessageString = notificationMessageString.substring(
  //       0,
  //       notificationMessageString.length - 3,
  //     );
  //   }
  //
  //   return notificationMessageString;
  // }

  // Future _showLocalNotification() async {
  //   _notificationProcessing = true;
  //   const channelId = "Alice";
  //   const channelName = "Alice";
  //   const channelDescription = "Alice";
  //   const androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     channelId,
  //     channelName,
  //     channelDescription: channelDescription,
  //     enableVibration: false,
  //     playSound: false,
  //   );
  //   const iOSPlatformChannelSpecifics =
  //       IOSNotificationDetails(presentSound: false);
  //   const platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //     iOS: iOSPlatformChannelSpecifics,
  //   );
  //
  //   final String? message = _notificationMessage;
  //   await _flutterLocalNotificationsPlugin.show(
  //     0,
  //     "Requests (total: ${callsSubject.value.length})",
  //     message,
  //     platformChannelSpecifics,
  //     payload: "",
  //   );
  //   _notificationMessageShown = message;
  //   _notificationProcessing = false;
  //   return;
  // }

  /// Add dev_interceptor http call to calls subject
  void addCall(AliceHttpCall call) {
    final callsCount = callsSubject.value.length;
    if (callsCount >= maxCallsCount) {
      final originalCalls = callsSubject.value;
      final calls = List<AliceHttpCall>.from(originalCalls);
      calls.sort(
        (call1, call2) => call1.createdTime.compareTo(call2.createdTime),
      );
      final indexToReplace = originalCalls.indexOf(calls.first);
      originalCalls[indexToReplace] = call;

      callsSubject.add(originalCalls);
    } else {
      callsSubject.add([...callsSubject.value, call]);
    }
  }

  /// Add error to existing dev_interceptor http call
  void addError(AliceHttpError error, int requestId) {
    final AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      AliceUtils.log("Selected call is null");
      return;
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing dev_interceptor http call
  void addResponse(AliceHttpResponse response, int requestId) {
    final AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      AliceUtils.log("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    selectedCall.duration = response.time.millisecondsSinceEpoch -
        selectedCall.request!.time.millisecondsSinceEpoch;

    callsSubject.add([...callsSubject.value]);
  }

  /// Remove all calls from calls subject
  void removeCalls() {
    callsSubject.add([]);
  }

  AliceHttpCall? _selectCall(int requestId) =>
      callsSubject.value.firstWhereOrNull((call) => call.id == requestId);
}
