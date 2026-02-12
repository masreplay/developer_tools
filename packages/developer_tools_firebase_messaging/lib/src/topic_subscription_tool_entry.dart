import 'package:developer_tools_core/developer_tools_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// A [DeveloperToolEntry] that provides a dialog to subscribe and unsubscribe
/// from FCM topics at runtime.
///
/// Useful for testing topic-based push notifications without rebuilding
/// the app or making backend calls manually.
DeveloperToolEntry topicSubscriptionToolEntry({String? sectionLabel}) {
  return DeveloperToolEntry(
    title: 'Topic Subscriptions',
    sectionLabel: sectionLabel,
    description: 'Subscribe or unsubscribe from FCM topics',
    icon: Icons.topic,
    onTap: (BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return const _TopicSubscriptionDialog();
        },
      );
    },
  );
}

class _TopicSubscriptionDialog extends StatefulWidget {
  const _TopicSubscriptionDialog();

  @override
  State<_TopicSubscriptionDialog> createState() =>
      _TopicSubscriptionDialogState();
}

class _TopicSubscriptionDialogState extends State<_TopicSubscriptionDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<_TopicAction> _history = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final topic = _controller.text.trim();
    if (topic.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      setState(() {
        _history.insert(
          0,
          _TopicAction(
            topic: topic,
            action: _ActionType.subscribed,
            timestamp: DateTime.now(),
          ),
        );
        _controller.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Subscribed to "$topic"')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to subscribe: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _unsubscribe(String topic) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      setState(() {
        _history.insert(
          0,
          _TopicAction(
            topic: topic,
            action: _ActionType.unsubscribed,
            timestamp: DateTime.now(),
          ),
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unsubscribed from "$topic"')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to unsubscribe: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.topic, size: 24),
          SizedBox(width: 8),
          Expanded(child: Text('Topic Subscriptions')),
        ],
      ),
      content: SizedBox(
        width: 480,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter topic name',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _subscribe(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _subscribe,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Subscribe'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'History',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _history.isEmpty
                      ? Center(
                        child: Text(
                          'No topic actions yet.\nSubscribe to a topic above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                      : ListView.separated(
                        itemCount: _history.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = _history[index];
                          final isSubscribed =
                              entry.action == _ActionType.subscribed;

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isSubscribed
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              size: 20,
                              color: isSubscribed ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              entry.topic,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                            ),
                            subtitle: Text(
                              '${isSubscribed ? "Subscribed" : "Unsubscribed"}'
                              ' at ${_formatTime(entry.timestamp)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing:
                                isSubscribed
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 20,
                                      ),
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () => _unsubscribe(entry.topic),
                                    )
                                    : null,
                          );
                        },
                      ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}

enum _ActionType { subscribed, unsubscribed }

class _TopicAction {
  const _TopicAction({
    required this.topic,
    required this.action,
    required this.timestamp,
  });

  final String topic;
  final _ActionType action;
  final DateTime timestamp;
}
