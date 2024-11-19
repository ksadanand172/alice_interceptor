import 'dart:async';

import 'package:alice_interceptor/core/alice_utils.dart';
import 'package:alice_interceptor/model/alice_http_call.dart';
import 'package:alice_interceptor/model/alice_http_error.dart';
import 'package:alice_interceptor/model/alice_http_response.dart';
import 'package:alice_interceptor/ui/page/alice_calls_list_screen.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class AliceCore {

  final bool darkTheme;
  final BehaviorSubject<List<AliceHttpCall>> callsSubject =
  BehaviorSubject.seeded([]);

  final int maxCallsCount;


  GlobalKey<NavigatorState>? navigatorKey;
  Brightness _brightness = Brightness.light;
  StreamSubscription? _callsSubscription;


  /// Creates dev_interceptor core instance
  AliceCore(this.navigatorKey, {

    required this.darkTheme,

    required this.maxCallsCount,
  }) {
    _brightness = darkTheme ? Brightness.dark : Brightness.light;
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    _callsSubscription?.cancel();
  }

  /// Get currently used brightness
  Brightness get brightness => _brightness;


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
