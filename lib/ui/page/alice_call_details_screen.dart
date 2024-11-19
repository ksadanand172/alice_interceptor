import 'package:alice_interceptor/core/alice_core.dart';
// import 'package:alice_interceptor/helper/alice_save_helper.dart';
import 'package:alice_interceptor/model/alice_http_call.dart';
import 'package:alice_interceptor/ui/widget/alice_call_error_widget.dart';
import 'package:alice_interceptor/ui/widget/alice_call_overview_widget.dart';
import 'package:alice_interceptor/ui/widget/alice_call_request_widget.dart';
import 'package:alice_interceptor/ui/widget/alice_call_response_widget.dart';
import 'package:alice_interceptor/utils/alice_constants.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  const AliceCallDetailsScreen(this.call, this.core, {Key? key})
      : super(key: key);

  @override
  State<AliceCallDetailsScreen> createState() => _AliceCallDetailsScreenState();
}

class _AliceCallDetailsScreenState extends State<AliceCallDetailsScreen>
    with SingleTickerProviderStateMixin {
  AliceHttpCall get call => widget.call;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.light(
          secondary: AliceConstants.lightRed,
          brightness: widget.core.brightness,
        ),
      ),
      child: StreamBuilder<List<AliceHttpCall>>(
        stream: widget.core.callsSubject,
        initialData: [widget.call],
        builder: (context, callsSnapshot) {
          if (callsSnapshot.hasData) {
            final AliceHttpCall? call = callsSnapshot.data!.firstWhereOrNull(
              (snapshotCall) => snapshotCall.id == widget.call.id,
            );
            if (call != null) {
              return _buildMainWidget();
            } else {
              return _buildErrorWidget();
            }
          } else {
            return _buildErrorWidget();
          }
        },
      ),
    );
  }

  Widget _buildMainWidget() {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          backgroundColor: AliceConstants.green,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: AliceConstants.white,
            tabs: _getTabBars(),
          ),
          title: Text(
            'HTTP Call Details',
            style: TextStyle(color: AliceConstants.white),
          ),
        ),
        body: TabBarView(
          children: _getTabBarViewList(),
        ),
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: AliceConstants.green,
          onPressed: () async {
            try {
              // final apiCallDetails = await AliceSaveHelper.buildCallLog(call);
              await Clipboard.setData(
                  ClipboardData(text: call.getCurlCommand()));

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Response curl details copied"),
                  backgroundColor: AliceConstants.green,
                ));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Couldn't copy curl details"),
                  backgroundColor: AliceConstants.green,
                ));
              }
            }
          },
          child: const Icon(
            Icons.copy_outlined,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(child: Text("Failed to load data"));
  }

  List<Widget> _getTabBars() {
    final List<Widget> widgets = [];
    widgets.add(const Tab(icon: Icon(Icons.info_outline), text: "Overview"));
    widgets.add(const Tab(icon: Icon(Icons.arrow_upward), text: "Request"));
    widgets.add(const Tab(icon: Icon(Icons.arrow_downward), text: "Response"));
    widgets.add(const Tab(icon: Icon(Icons.warning), text: "Error"));
    return widgets;
  }

  List<Widget> _getTabBarViewList() {
    final List<Widget> widgets = [];
    widgets.add(AliceCallOverviewWidget(widget.call));
    widgets.add(AliceCallRequestWidget(widget.call));
    widgets.add(AliceCallResponseWidget(widget.call));
    widgets.add(AliceCallErrorWidget(widget.call));
    return widgets;
  }
}
