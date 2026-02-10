import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Manual (non–code-gen) providers – all kinds for the log ---

/// Simple [Provider] – logs add when first read.
final counterLabelProvider = Provider<String>((ref) => 'Counter');

/// [NotifierProvider] – logs add, then update on every increment.
final counterProvider = NotifierProvider<SimpleCounterNotifier, int>(
  SimpleCounterNotifier.new,
);

class SimpleCounterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

/// [FutureProvider] – logs add when future completes (or fail on error).
final asyncMessageProvider = FutureProvider<String>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Loaded';
});

/// [StreamProvider] – logs add then update on each stream event.
final tickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i).take(100);
});

/// [AsyncNotifierProvider] – logs add when async build completes.
final asyncCounterProvider = AsyncNotifierProvider<AsyncCounterNotifier, int>(
  AsyncCounterNotifier.new,
);

class AsyncCounterNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 0;
  }
}

/// [NotifierProvider] – logs add and update when notifier state changes.
final notifierCounterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
  void decrement() => state--;
}
