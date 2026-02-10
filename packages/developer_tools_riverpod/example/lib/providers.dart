import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// --- Code-generated providers (@riverpod) ---

/// Sync provider – generated [Provider].
@riverpod
String generatedLabel(Ref ref) => 'Code-gen';

/// Async provider – generated [FutureProvider].
@riverpod
Future<String> fetchGeneratedMessage(Ref ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 400));
  return 'Generated FutureProvider';
}

/// Stream provider – generated [StreamProvider].
@riverpod
Stream<int> generatedTicks(Ref ref) async* {
  var i = 0;
  while (i < 5) {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield i++;
  }
}

/// Class-based notifier – generated [NotifierPr  ovider].
@riverpod
class GeneratedCounter extends _$GeneratedCounter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}

/// Async class-based – generated [AsyncNotifierProvider].
@riverpod
class GeneratedAsyncCount extends _$GeneratedAsyncCount {
  @override
  Future<int> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 0;
  }
}
