// ignore_for_file: use_build_context_synchronously

import 'package:developer_tools_network/network_inspector/core/network_core.dart';
import 'package:developer_tools_network/network_inspector/helper/operating_system.dart';
import 'package:developer_tools_network/network_inspector/model/network_export_result.dart';
import 'package:developer_tools_network/network_inspector/model/network_http_call.dart';
import 'package:developer_tools_network/network_inspector/model/network_translation.dart';
import 'package:developer_tools_network/network_inspector/ui/call_details/model/network_menu_item.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/model/network_calls_list_sort_option.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/model/network_calls_list_tab_item.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_inspector_screen.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_sort_dialog.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_context_ext.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_dialog.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_navigation.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_page.dart';
import 'package:developer_tools_network/network_inspector/ui/calls_list/widget/network_logs_screen.dart';
import 'package:developer_tools_network/network_inspector/ui/common/network_theme.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

/// Page which displays list of calls caught by NetworkInspector. It displays tab view
/// where calls and logs can be inspected. It allows to sort calls, delete calls
/// and search calls.
class NetworkCallsListPage extends StatefulWidget {
  final NetworkInspectorCore core;

  const NetworkCallsListPage({required this.core, super.key});

  @override
  State<NetworkCallsListPage> createState() => _NetworkCallsListPageState();
}

class _NetworkCallsListPageState extends State<NetworkCallsListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _queryTextEditingController =
      TextEditingController();
  final List<NetworkCallsListTabItem> _tabItems = NetworkCallsListTabItem.values;
  final ScrollController _scrollController = ScrollController();
  late final TabController? _tabController;

  NetworkCallsListSortOption _sortOption = NetworkCallsListSortOption.time;
  bool _sortAscending = false;
  bool _searchEnabled = false;
  bool isAndroidRawLogsEnabled = false;
  int _selectedIndex = 0;

  NetworkInspectorCore get networkCore => widget.core;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: _tabItems.length,
      initialIndex: _tabItems.first.index,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController?.addListener(() {
        _onTabChanged(_tabController.index);
      });
    });
  }

  @override
  void dispose() {
    _queryTextEditingController.dispose();
    _tabController?.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  /// Returns [true] when logger tab is opened.
  bool get isLoggerTab => _selectedIndex == 1;

  @override
  Widget build(BuildContext context) {
    return NetworkPage(
      core: networkCore,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBackPressed,
          ),
          title:
              _searchEnabled
                  ? _SearchTextField(
                    textEditingController: _queryTextEditingController,
                    onChanged: _updateSearchQuery,
                  )
                  : Text(context.i18n(NetworkTranslationKey.networkInspector)),
          actions:
              isLoggerTab
                  ? <Widget>[
                    IconButton(
                      icon: const Icon(Icons.terminal),
                      onPressed: _onLogsChangePressed,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _onClearLogsPressed,
                    ),
                  ]
                  : <Widget>[
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _onSearchPressed,
                    ),
                    _ContextMenuButton(onMenuItemSelected: _onMenuItemSelected),
                  ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: NetworkTheme.lightRed,
            tabs:
                NetworkCallsListTabItem.values.map((item) {
                  return Tab(text: _getTabName(item: item));
                }).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            NetworkInspectorScreen(
              networkCore: networkCore,
              queryTextEditingController: _queryTextEditingController,
              sortOption: _sortOption,
              sortAscending: _sortAscending,
              onListItemPressed: _onListItemPressed,
            ),
            NetworkLogsScreen(
              scrollController: _scrollController,
              networkLogger: widget.core.configuration.networkLogger,
              isAndroidRawLogsEnabled: isAndroidRawLogsEnabled,
            ),
          ],
        ),
        floatingActionButton:
            isLoggerTab
                ? _LoggerFloatingActionButtons(scrollLogsList: _scrollLogsList)
                : const SizedBox(),
      ),
    );
  }

  /// Get tab name based on [item] type.
  String _getTabName({required NetworkCallsListTabItem item}) {
    switch (item) {
      case NetworkCallsListTabItem.inspector:
        return context.i18n(NetworkTranslationKey.callsListInspector);
      case NetworkCallsListTabItem.logger:
        return context.i18n(NetworkTranslationKey.callsListLogger);
    }
  }

  /// Called when back button has been pressed. It navigates back to original
  /// application.
  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  /// Called when clear logs has been pressed. It displays dialog and awaits for
  /// user confirmation.
  void _onClearLogsPressed() => NetworkGeneralDialog.show(
    context: context,
    title: context.i18n(NetworkTranslationKey.callsListDeleteLogsDialogTitle),
    description: context.i18n(
      NetworkTranslationKey.callsListDeleteLogsDialogDescription,
    ),
    firstButtonTitle: context.i18n(NetworkTranslationKey.callsListNo),
    secondButtonTitle: context.i18n(NetworkTranslationKey.callsListYes),
    secondButtonAction: _onLogsClearPressed,
  );

  /// Called when logs type mode pressed.
  void _onLogsChangePressed() => setState(() {
    isAndroidRawLogsEnabled = !isAndroidRawLogsEnabled;
  });

  /// Called when logs clear button has been pressed.
  void _onLogsClearPressed() => setState(() {
    if (isAndroidRawLogsEnabled) {
      widget.core.configuration.networkLogger.clearAndroidRawLogs();
    } else {
      widget.core.configuration.networkLogger.clearLogs();
    }
  });

  /// Called when search button. It displays search text field.
  void _onSearchPressed() => setState(() {
    _searchEnabled = !_searchEnabled;
    if (!_searchEnabled) {
      _queryTextEditingController.text = '';
    }
  });

  /// Called on tab has been changed.
  void _onTabChanged(int index) => setState(() {
    _selectedIndex = index;
    if (_selectedIndex == 1) {
      _searchEnabled = false;
      _queryTextEditingController.text = '';
    }
  });

  /// Called when menu item from overflow menu has been pressed.
  void _onMenuItemSelected(NetworkCallDetailsMenuItemType menuItem) {
    switch (menuItem) {
      case NetworkCallDetailsMenuItemType.sort:
        _onSortPressed();
      case NetworkCallDetailsMenuItemType.delete:
        _onRemovePressed();
      case NetworkCallDetailsMenuItemType.stats:
        _onStatsPressed();
      case NetworkCallDetailsMenuItemType.save:
        _saveToFile();
    }
  }

  /// Called when item from the list has been pressed. It opens details page.
  void _onListItemPressed(NetworkHttpCall call) =>
      NetworkNavigation.navigateToCallDetails(call: call, core: networkCore);

  /// Called when remove all calls button has been pressed.
  void _onRemovePressed() => NetworkGeneralDialog.show(
    context: context,
    title: context.i18n(NetworkTranslationKey.callsListDeleteCallsDialogTitle),
    description: context.i18n(
      NetworkTranslationKey.callsListDeleteCallsDialogDescription,
    ),
    firstButtonTitle: context.i18n(NetworkTranslationKey.callsListNo),
    firstButtonAction: () => <String, dynamic>{},
    secondButtonTitle: context.i18n(NetworkTranslationKey.callsListYes),
    secondButtonAction: _removeCalls,
  );

  /// Removes all calls from NetworkInspector.
  void _removeCalls() => networkCore.removeCalls();

  /// Called when stats button has been pressed. Navigates to stats page.
  void _onStatsPressed() {
    NetworkNavigation.navigateToStats(core: networkCore);
  }

  /// Called when save to file has been pressed. It saves data to file.
  void _saveToFile() async {
    if (!mounted) return;
    final result = await networkCore.saveCallsToFile(context);

    if (result.success && result.path != null) {
      NetworkGeneralDialog.show(
        context: context,
        title: context.i18n(NetworkTranslationKey.saveSuccessTitle),
        description: context
            .i18n(NetworkTranslationKey.saveSuccessDescription)
            .replaceAll("[path]", result.path!),
        secondButtonTitle:
            OperatingSystem.isAndroid
                ? context.i18n(NetworkTranslationKey.saveSuccessView)
                : null,
        secondButtonAction:
            () =>
                OperatingSystem.isAndroid ? OpenFilex.open(result.path!) : null,
      );
    } else {
      final [String title, String description] = switch (result.error) {
        NetworkExportResultError.logGenerate => [
          context.i18n(NetworkTranslationKey.saveDialogPermissionErrorTitle),
          context.i18n(
            NetworkTranslationKey.saveDialogPermissionErrorDescription,
          ),
        ],
        NetworkExportResultError.empty => [
          context.i18n(NetworkTranslationKey.saveDialogEmptyErrorTitle),
          context.i18n(NetworkTranslationKey.saveDialogEmptyErrorDescription),
        ],
        NetworkExportResultError.permission => [
          context.i18n(NetworkTranslationKey.saveDialogPermissionErrorTitle),
          context.i18n(
            NetworkTranslationKey.saveDialogPermissionErrorDescription,
          ),
        ],
        NetworkExportResultError.file => [
          context.i18n(NetworkTranslationKey.saveDialogFileSaveErrorTitle),
          context.i18n(NetworkTranslationKey.saveDialogFileSaveErrorDescription),
        ],
        _ => ["", ""],
      };

      NetworkGeneralDialog.show(
        context: context,
        title: title,
        description: description,
      );
    }
  }

  /// Filters calls based on query.
  void _updateSearchQuery(String query) => setState(() {});

  /// Called when sort button has been pressed. It opens dialog where filters
  /// can be picked.
  Future<void> _onSortPressed() async {
    NetworkSortDialogResult? result = await showDialog<NetworkSortDialogResult>(
      context: context,
      builder:
          (_) => NetworkSortDialog(
            sortOption: _sortOption,
            sortAscending: _sortAscending,
          ),
    );
    if (result != null) {
      setState(() {
        _sortOption = result.sortOption;
        _sortAscending = result.sortAscending;
      });
    }
  }

  /// Scrolls logs list based on [top] parameter.
  void _scrollLogsList(bool top) => top ? _scrollToTop() : _scrollToBottom();

  /// Scrolls logs list to the top.
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(microseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  /// Scrolls logs list to the bottom.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 500),
        curve: Curves.ease,
      );
    }
  }
}

/// Text field displayed in app bar. Used to search call logs.
class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    required this.textEditingController,
    required this.onChanged,
  });

  final TextEditingController textEditingController;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: context.i18n(NetworkTranslationKey.callsListSearchHint),
        hintStyle: const TextStyle(fontSize: 16, color: NetworkTheme.grey),
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: onChanged,
    );
  }
}

/// Menu button displayed in app bar. It displays overflow menu with additional
/// actions.
class _ContextMenuButton extends StatelessWidget {
  const _ContextMenuButton({required this.onMenuItemSelected});

  final void Function(NetworkCallDetailsMenuItemType) onMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NetworkCallDetailsMenuItemType>(
      onSelected: onMenuItemSelected,
      itemBuilder:
          (BuildContext context) => [
            for (final NetworkCallDetailsMenuItemType item
                in NetworkCallDetailsMenuItemType.values)
              PopupMenuItem<NetworkCallDetailsMenuItemType>(
                value: item,
                child: Row(
                  children: [
                    Icon(_getIcon(itemType: item), color: NetworkTheme.lightRed),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    Text(_getTitle(context: context, itemType: item)),
                  ],
                ),
              ),
          ],
    );
  }

  /// Get title of the menu item based on [itemType].
  String _getTitle({
    required BuildContext context,
    required NetworkCallDetailsMenuItemType itemType,
  }) {
    switch (itemType) {
      case NetworkCallDetailsMenuItemType.sort:
        return context.i18n(NetworkTranslationKey.callsListSort);
      case NetworkCallDetailsMenuItemType.delete:
        return context.i18n(NetworkTranslationKey.callsListDelete);
      case NetworkCallDetailsMenuItemType.stats:
        return context.i18n(NetworkTranslationKey.callsListStats);
      case NetworkCallDetailsMenuItemType.save:
        return context.i18n(NetworkTranslationKey.callsListSave);
    }
  }

  /// Get icon of the menu item based [itemType].
  IconData _getIcon({required NetworkCallDetailsMenuItemType itemType}) {
    switch (itemType) {
      case NetworkCallDetailsMenuItemType.sort:
        return Icons.sort;
      case NetworkCallDetailsMenuItemType.delete:
        return Icons.delete;
      case NetworkCallDetailsMenuItemType.stats:
        return Icons.insert_chart;
      case NetworkCallDetailsMenuItemType.save:
        return Icons.save;
    }
  }
}

/// FAB buttons used to scroll logs. Displayed only in logs tab.
class _LoggerFloatingActionButtons extends StatelessWidget {
  const _LoggerFloatingActionButtons({required this.scrollLogsList});

  final void Function(bool) scrollLogsList;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'h1',
          backgroundColor: NetworkTheme.lightRed,
          onPressed: () => scrollLogsList(true),
          child: const Icon(Icons.arrow_upward, color: NetworkTheme.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'h2',
          backgroundColor: NetworkTheme.lightRed,
          onPressed: () => scrollLogsList(false),
          child: const Icon(Icons.arrow_downward, color: NetworkTheme.white),
        ),
      ],
    );
  }
}
