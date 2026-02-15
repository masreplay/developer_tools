import 'package:alice/alice.dart';
import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:flutter/material.dart';

/// A [DeveloperToolEntry] that opens the Network HTTP Inspector fullscreen page.
///
/// When the user taps this entry, [Alice.showInspector] is called so they can
/// view all captured HTTP requests and responses. Requires an [Alice] instance
/// to be passed via the extension; if [instance] is null, a message is shown.
DeveloperToolEntry openNetworkInspectorToolEntry({
  String? sectionLabel,
  Alice? instance,
}) {
  return DeveloperToolEntry(
    title: 'Open HTTP Inspector',
    sectionLabel: sectionLabel,
    description: 'Open the fullscreen inspector to view HTTP calls',
    icon: Icons.http,
    onTap: (BuildContext context) async {
      if (instance == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Network inspector instance not provided. '
                'Pass it to DeveloperToolsNetwork(instance: alice).',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      instance.showInspector();
    },
  );
}
