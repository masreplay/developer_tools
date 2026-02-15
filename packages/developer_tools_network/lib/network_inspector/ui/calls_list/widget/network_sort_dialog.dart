import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/model/network_calls_list_sort_option.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:flutter/material.dart';

/// Dialog which can be used to sort network calls.
class NetworkSortDialog extends StatelessWidget {
  final NetworkCallsListSortOption sortOption;
  final bool sortAscending;

  const NetworkSortDialog({
    super.key,
    required this.sortOption,
    required this.sortAscending,
  });

  @override
  Widget build(BuildContext context) {
    NetworkCallsListSortOption currentSortOption = sortOption;
    bool currentSortAscending = sortAscending;
    return Theme(
      data: ThemeData(brightness: Brightness.light),
      child: StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(context.i18n(NetworkTranslationKey.sortDialogTitle)),
            content: Wrap(
              children: [
                for (final NetworkCallsListSortOption sortOption
                    in NetworkCallsListSortOption.values)
                  RadioListTile<NetworkCallsListSortOption>(
                    title: Text(_getName(context: context, option: sortOption)),
                    value: sortOption,
                    groupValue: currentSortOption,
                    onChanged: (NetworkCallsListSortOption? value) {
                      if (value != null) {
                        setState(() {
                          currentSortOption = value;
                        });
                      }
                    },
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.i18n(NetworkTranslationKey.sortDialogDescending),
                    ),
                    Switch(
                      value: currentSortAscending,
                      onChanged: (value) {
                        setState(() {
                          currentSortAscending = value;
                        });
                      },
                      activeTrackColor: Colors.grey,
                      activeColor: Colors.white,
                    ),
                    Text(context.i18n(NetworkTranslationKey.sortDialogAscending)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(context.i18n(NetworkTranslationKey.sortDialogCancel)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    NetworkSortDialogResult(
                      sortOption: currentSortOption,
                      sortAscending: currentSortAscending,
                    ),
                  );
                },
                child: Text(context.i18n(NetworkTranslationKey.sortDialogAccept)),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Get sort option name based on [option].
  String _getName({
    required BuildContext context,
    required NetworkCallsListSortOption option,
  }) {
    return switch (option) {
      NetworkCallsListSortOption.time => context.i18n(
        NetworkTranslationKey.sortDialogTime,
      ),
      NetworkCallsListSortOption.responseTime => context.i18n(
        NetworkTranslationKey.sortDialogResponseTime,
      ),
      NetworkCallsListSortOption.responseCode => context.i18n(
        NetworkTranslationKey.sortDialogResponseCode,
      ),
      NetworkCallsListSortOption.responseSize => context.i18n(
        NetworkTranslationKey.sortDialogResponseSize,
      ),
      NetworkCallsListSortOption.endpoint => context.i18n(
        NetworkTranslationKey.sortDialogEndpoint,
      ),
    };
  }
}

/// Result of alice sort dialog.
class NetworkSortDialogResult {
  final NetworkCallsListSortOption sortOption;
  final bool sortAscending;

  NetworkSortDialogResult({
    required this.sortOption,
    required this.sortAscending,
  });
}
