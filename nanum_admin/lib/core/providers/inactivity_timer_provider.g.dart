// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inactivity_timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inactivityLogoutTriggerHash() =>
    r'08380edae8a8884f490716701fed247a915f39cc';

/// See also [inactivityLogoutTrigger].
@ProviderFor(inactivityLogoutTrigger)
final inactivityLogoutTriggerProvider = AutoDisposeProvider<bool>.internal(
  inactivityLogoutTrigger,
  name: r'inactivityLogoutTriggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inactivityLogoutTriggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InactivityLogoutTriggerRef = AutoDisposeProviderRef<bool>;
String _$inactivityTimerHash() => r'86b026890e377220fe11a8ece595a7dcbcb1849d';

/// See also [InactivityTimer].
@ProviderFor(InactivityTimer)
final inactivityTimerProvider =
    AutoDisposeNotifierProvider<InactivityTimer, DateTime>.internal(
      InactivityTimer.new,
      name: r'inactivityTimerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inactivityTimerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InactivityTimer = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
