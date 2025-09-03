// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userPaymentsHash() => r'85e498948c8dfebdf14b3fafe946295af7e7ddb3';

/// See also [userPayments].
@ProviderFor(userPayments)
final userPaymentsProvider =
    AutoDisposeFutureProvider<List<local_models.PaymentModel>>.internal(
      userPayments,
      name: r'userPaymentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userPaymentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserPaymentsRef =
    AutoDisposeFutureProviderRef<List<local_models.PaymentModel>>;
String _$paymentViewModelHash() => r'478f336184a365177b140b972614ee9d530128db';

/// See also [PaymentViewModel].
@ProviderFor(PaymentViewModel)
final paymentViewModelProvider =
    AutoDisposeAsyncNotifierProvider<PaymentViewModel, void>.internal(
      PaymentViewModel.new,
      name: r'paymentViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paymentViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PaymentViewModel = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
