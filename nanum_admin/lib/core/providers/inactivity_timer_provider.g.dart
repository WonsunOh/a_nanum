// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inactivity_timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InactivityTimer)
const inactivityTimerProvider = InactivityTimerProvider._();

final class InactivityTimerProvider
    extends $NotifierProvider<InactivityTimer, DateTime> {
  const InactivityTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inactivityTimerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inactivityTimerHash();

  @$internal
  @override
  InactivityTimer create() => InactivityTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$inactivityTimerHash() => r'3ed882ace0a1f50035488e6c99050c345e24e0d5';

abstract class _$InactivityTimer extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(inactivityLogoutTrigger)
const inactivityLogoutTriggerProvider = InactivityLogoutTriggerProvider._();

final class InactivityLogoutTriggerProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  const InactivityLogoutTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inactivityLogoutTriggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inactivityLogoutTriggerHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return inactivityLogoutTrigger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$inactivityLogoutTriggerHash() =>
    r'0fa9d10091b3474fc54bb5444558a3c907999295';
