// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sync provider – generated [Provider].

@ProviderFor(generatedLabel)
const generatedLabelProvider = GeneratedLabelProvider._();

/// Sync provider – generated [Provider].

final class GeneratedLabelProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Sync provider – generated [Provider].
  const GeneratedLabelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedLabelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedLabelHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return generatedLabel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$generatedLabelHash() => r'6cfbe2499e04e6c731eb48d5cfc30ab3cbf3ba8a';

/// Async provider – generated [FutureProvider].

@ProviderFor(fetchGeneratedMessage)
const fetchGeneratedMessageProvider = FetchGeneratedMessageProvider._();

/// Async provider – generated [FutureProvider].

final class FetchGeneratedMessageProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Async provider – generated [FutureProvider].
  const FetchGeneratedMessageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchGeneratedMessageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchGeneratedMessageHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return fetchGeneratedMessage(ref);
  }
}

String _$fetchGeneratedMessageHash() =>
    r'6b962e0533918d6e7e3b0338e2d7af5146f0e06b';

/// Stream provider – generated [StreamProvider].

@ProviderFor(generatedTicks)
const generatedTicksProvider = GeneratedTicksProvider._();

/// Stream provider – generated [StreamProvider].

final class GeneratedTicksProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Stream provider – generated [StreamProvider].
  const GeneratedTicksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedTicksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedTicksHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return generatedTicks(ref);
  }
}

String _$generatedTicksHash() => r'eb5d5195c0d42d129070e23285691a4abcc814b3';

/// Class-based notifier – generated [NotifierProvider].

@ProviderFor(GeneratedCounter)
const generatedCounterProvider = GeneratedCounterProvider._();

/// Class-based notifier – generated [NotifierProvider].
final class GeneratedCounterProvider
    extends $NotifierProvider<GeneratedCounter, int> {
  /// Class-based notifier – generated [NotifierProvider].
  const GeneratedCounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedCounterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedCounterHash();

  @$internal
  @override
  GeneratedCounter create() => GeneratedCounter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$generatedCounterHash() => r'cadd6d299e7a11146e5d1410549f978ff0594794';

/// Class-based notifier – generated [NotifierProvider].

abstract class _$GeneratedCounter extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Async class-based – generated [AsyncNotifierProvider].

@ProviderFor(GeneratedAsyncCount)
const generatedAsyncCountProvider = GeneratedAsyncCountProvider._();

/// Async class-based – generated [AsyncNotifierProvider].
final class GeneratedAsyncCountProvider
    extends $AsyncNotifierProvider<GeneratedAsyncCount, int> {
  /// Async class-based – generated [AsyncNotifierProvider].
  const GeneratedAsyncCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generatedAsyncCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generatedAsyncCountHash();

  @$internal
  @override
  GeneratedAsyncCount create() => GeneratedAsyncCount();
}

String _$generatedAsyncCountHash() =>
    r'ca75720bca46153549049dfec9f86c8d104a5515';

/// Async class-based – generated [AsyncNotifierProvider].

abstract class _$GeneratedAsyncCount extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
