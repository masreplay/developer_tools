import 'package:developer_tools/developer_tools.dart';
import 'package:developer_tools_riverpod/developer_tools_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'manual_providers.dart';
import 'providers.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      observers: [DeveloperToolsRiverpod.observer()],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        home: const HomePage(),
        builder: DeveloperTools.builder(
          navigatorKey: _navigatorKey,
          extensions: const [DeveloperToolsRiverpod()],
        ),
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Manual providers (manual_providers.dart)
    final manualLabel = ref.watch(counterLabelProvider);
    final manualCount = ref.watch(counterProvider);
    final manualMessage = ref.watch(asyncMessageProvider);
    final manualTick = ref.watch(tickProvider);
    final manualAsyncCount = ref.watch(asyncCounterProvider);
    final manualNotifierCount = ref.watch(notifierCounterProvider);
    // Code-generated (providers.dart @riverpod)
    final genLabel = ref.watch(generatedLabelProvider);
    final genMessage = ref.watch(fetchGeneratedMessageProvider);
    final genTicks = ref.watch(generatedTicksProvider);
    final genCount = ref.watch(generatedCounterProvider);
    final genAsyncCount = ref.watch(generatedAsyncCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod provider log demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Manual (manual_providers.dart)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '$manualLabel: $manualCount',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Row(
            children: [
              FilledButton(
                onPressed: () => ref.read(counterProvider.notifier).increment(),
                child: const Text('+'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(counterProvider),
                child: const Text('Invalidate'),
              ),
            ],
          ),
          Text(
            'Future: ${manualMessage.when(data: (d) => d, loading: () => '...', error: (e, _) => 'Err')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Stream: ${manualTick.when(data: (d) => d.toString(), loading: () => '...', error: (e, _) => 'Err')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'AsyncNotifier: ${manualAsyncCount.when(data: (d) => d.toString(), loading: () => '...', error: (e, _) => 'Err')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Notifier: $manualNotifierCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              FilledButton(
                onPressed:
                    () =>
                        ref.read(notifierCounterProvider.notifier).increment(),
                child: const Text('Notifier +'),
              ),
              FilledButton.tonal(
                onPressed:
                    () =>
                        ref.read(notifierCounterProvider.notifier).decrement(),
                child: const Text('Notifier -'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          Text(
            'Code-generated (providers.dart @riverpod)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '$genLabel: $genCount',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Row(
            children: [
              FilledButton(
                onPressed:
                    () =>
                        ref.read(generatedCounterProvider.notifier).increment(),
                child: const Text('+'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(generatedCounterProvider),
                child: const Text('Invalidate'),
              ),
            ],
          ),
          Text(
            'Future: ${genMessage.when(data: (d) => d, loading: () => '...', error: (e, _) => 'Err')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Stream: ${genTicks.when(data: (d) => d.toString(), loading: () => '...', error: (e, _) => 'Err')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'AsyncNotifier: ${genAsyncCount.when(data: (d) => d.toString(), loading: () => '...', error: (e, _) => 'Err')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          const Text(
            'Dev tools → Riverpod provider log',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
