import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_theme.dart';
import 'package:flutter/material.dart';

/// Widget which renders empty text for calls list.
class NetworkEmptyLogsWidget extends StatelessWidget {
  const NetworkEmptyLogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: NetworkTheme.orange),
            const SizedBox(height: 6),
            Text(
              context.i18n(NetworkTranslationKey.logsEmpty),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
