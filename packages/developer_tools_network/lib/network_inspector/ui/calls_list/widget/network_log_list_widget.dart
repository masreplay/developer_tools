import 'dart:convert';

import 'package:developer_tools_network/network_inspector/model/network_log.dart';
import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_empty_logs_widget.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_error_logs_widget.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_scroll_behavior.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget which renders log list for calls list page.
class NetworkLogListWidget extends StatefulWidget {
  const NetworkLogListWidget({
    required this.logsStream,
    required this.scrollController,
    super.key,
  });

  final Stream<List<NetworkLog>>? logsStream;
  final ScrollController? scrollController;

  @override
  State<NetworkLogListWidget> createState() => _NetworkLogListWidgetState();
}

/// State for logs list widget.
class _NetworkLogListWidgetState extends State<NetworkLogListWidget> {
  final DiagnosticLevel _minLevel = DiagnosticLevel.debug;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NetworkLog>>(
      stream: widget.logsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const NetworkErrorLogsWidget();
        }

        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const NetworkEmptyLogsWidget();
        }

        final List<NetworkLog> filteredLogs = [
          for (final NetworkLog log in logs)
            if (log.level.index >= _minLevel.index) log,
        ];

        return ScrollConfiguration(
          behavior: NetworkScrollBehavior(),
          child: ListView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredLogs.length,
            itemBuilder: (context, i) => _NetworkLogEntryWidget(filteredLogs[i]),
          ),
        );
      },
    );
  }
}

/// Widget which renders one log entry in logs list.
class _NetworkLogEntryWidget extends StatelessWidget {
  _NetworkLogEntryWidget(this.log) : super(key: ValueKey(log));

  final NetworkLog log;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final String rawTimestamp = log.timestamp.toString();
    final int timeStartIndex = rawTimestamp.indexOf(' ') + 1;
    final String formattedTimestamp = rawTimestamp.substring(timeStartIndex);

    final Color color = _getTextColor(context);
    final Text content = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: formattedTimestamp,
            style: textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.6),
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          TextSpan(text: ' ${log.message}'),
          ..._toText(
            context,
            context.i18n(NetworkTranslationKey.logsItemError),
            log.error,
          ),
          ..._toText(
            context,
            context.i18n(NetworkTranslationKey.logsItemStackTrace),
            log.stackTrace,
            addLineBreakAfterTitle: true,
          ),
        ],
        style: TextStyle(color: color),
      ),
    );

    return InkWell(
      onLongPress: () => _copyToClipboard(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getLogIcon(log.level), size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  /// Formats log entry.
  List<InlineSpan> _toText(
    BuildContext context,
    String title,
    dynamic object, {
    bool addLineBreakAfterTitle = false,
  }) {
    final String? string = _stringify(object);
    if (string == null) return [];

    return [
      TextSpan(
        text: '\n$title:${addLineBreakAfterTitle ? '\n' : ' '}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: string),
    ];
  }

  /// Returns text color based on log level.
  Color _getTextColor(BuildContext context) {
    return NetworkTheme.getLogTextColor(context, log.level);
  }

  /// Returns icon based on log level.
  IconData _getLogIcon(DiagnosticLevel level) => switch (level) {
    DiagnosticLevel.hidden => Icons.all_inclusive_outlined,
    DiagnosticLevel.fine => Icons.bubble_chart_outlined,
    DiagnosticLevel.debug => Icons.bug_report_outlined,
    DiagnosticLevel.info => Icons.info_outline,
    DiagnosticLevel.warning => Icons.warning_outlined,
    DiagnosticLevel.hint => Icons.privacy_tip_outlined,
    DiagnosticLevel.summary => Icons.subject,
    DiagnosticLevel.error => Icons.error_outlined,
    DiagnosticLevel.off => Icons.not_interested_outlined,
  };

  /// Copies to clipboard given error.
  Future<void> _copyToClipboard(BuildContext context) async {
    final String? error = _stringify(log.error);
    final String? stackTrace = _stringify(log.stackTrace);
    final StringBuffer text =
        StringBuffer()..writeAll([
          '${log.timestamp}: ${log.message}\n',
          if (error != null)
            '${context.i18n(NetworkTranslationKey.logsItemError)} $error\n',
          if (stackTrace != null)
            '${context.i18n(NetworkTranslationKey.logsItemStackTrace)}: $stackTrace\n',
        ]);

    await Clipboard.setData(ClipboardData(text: text.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.i18n(NetworkTranslationKey.logsCopied))),
      );
    }
  }

  /// Formats text with json decode/encode.
  String? _stringify(dynamic object) {
    if (object == null) return null;
    if (object is String) return object.trim();
    if (object is DiagnosticsNode) return object.toStringDeep();

    try {
      // ignore: avoid_dynamic_calls
      object.toJson();
      // It supports `toJson()`.

      dynamic toEncodable(dynamic object) {
        try {
          // ignore: avoid_dynamic_calls
          return object.toJson();
        } catch (_) {
          try {
            return '$object';
          } catch (_) {
            return describeIdentity(object);
          }
        }
      }

      return JsonEncoder.withIndent('  ', toEncodable).convert(object);
    } catch (_) {}

    try {
      return '$object'.trim();
    } catch (_) {
      return describeIdentity(object);
    }
  }
}
