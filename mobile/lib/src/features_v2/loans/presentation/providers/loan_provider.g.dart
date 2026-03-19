// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loanRepositoryHash() => r'3b65f5e1b26d5f180babbadc2c4f1309e5f5cd93';

/// See also [loanRepository].
@ProviderFor(loanRepository)
final loanRepositoryProvider = AutoDisposeProvider<ILoanRepository>.internal(
  loanRepository,
  name: r'loanRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loanRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LoanRepositoryRef = AutoDisposeProviderRef<ILoanRepository>;
String _$filteredLoansHash() => r'995c1507916ac6ec87de28bad74ab89f1f023517';

/// See also [filteredLoans].
@ProviderFor(filteredLoans)
final filteredLoansProvider = AutoDisposeProvider<List<LoanItem>>.internal(
  filteredLoans,
  name: r'filteredLoansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredLoansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredLoansRef = AutoDisposeProviderRef<List<LoanItem>>;
String _$myPendingItemsHash() => r'e651ce752a218fc01a1c91f733ff67bf6ea3064b';

/// Filtered and Status-Split Providers
///
/// Copied from [myPendingItems].
@ProviderFor(myPendingItems)
final myPendingItemsProvider = AutoDisposeProvider<List<LoanItem>>.internal(
  myPendingItems,
  name: r'myPendingItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myPendingItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyPendingItemsRef = AutoDisposeProviderRef<List<LoanItem>>;
String _$myActiveItemsHash() => r'f9d10bdcf28215fc03052701c0b74f48d2f47941';

/// See also [myActiveItems].
@ProviderFor(myActiveItems)
final myActiveItemsProvider = AutoDisposeProvider<List<LoanItem>>.internal(
  myActiveItems,
  name: r'myActiveItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myActiveItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyActiveItemsRef = AutoDisposeProviderRef<List<LoanItem>>;
String _$myOverdueItemsHash() => r'4e376d8ac3c9de2a965d965980d81f4559848989';

/// See also [myOverdueItems].
@ProviderFor(myOverdueItems)
final myOverdueItemsProvider = AutoDisposeProvider<List<LoanItem>>.internal(
  myOverdueItems,
  name: r'myOverdueItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myOverdueItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyOverdueItemsRef = AutoDisposeProviderRef<List<LoanItem>>;
String _$myReturnedHistoryHash() => r'a9d5142ff4776ff47c0d13f335dec81713b7e98a';

/// See also [myReturnedHistory].
@ProviderFor(myReturnedHistory)
final myReturnedHistoryProvider = AutoDisposeProvider<List<LoanItem>>.internal(
  myReturnedHistory,
  name: r'myReturnedHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myReturnedHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyReturnedHistoryRef = AutoDisposeProviderRef<List<LoanItem>>;
String _$myLoansNotifierHash() => r'5f9f3efc123a88a7896288c1359e89a090fc8be4';

/// Reactive Loan List Provider
///
/// Copied from [MyLoansNotifier].
@ProviderFor(MyLoansNotifier)
final myLoansNotifierProvider =
    AutoDisposeStreamNotifierProvider<MyLoansNotifier, List<LoanItem>>.internal(
  MyLoansNotifier.new,
  name: r'myLoansNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myLoansNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyLoansNotifier = AutoDisposeStreamNotifier<List<LoanItem>>;
String _$loanSearchQueryHash() => r'd0af16477369ad88e28907df82b6101f620a745b';

/// See also [LoanSearchQuery].
@ProviderFor(LoanSearchQuery)
final loanSearchQueryProvider =
    AutoDisposeNotifierProvider<LoanSearchQuery, String>.internal(
  LoanSearchQuery.new,
  name: r'loanSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loanSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoanSearchQuery = AutoDisposeNotifier<String>;
String _$loanSelectedTabIndexHash() =>
    r'ce69d5c03ba33655c9862e9ac1b7877ef19463dc';

/// See also [LoanSelectedTabIndex].
@ProviderFor(LoanSelectedTabIndex)
final loanSelectedTabIndexProvider =
    AutoDisposeNotifierProvider<LoanSelectedTabIndex, int>.internal(
  LoanSelectedTabIndex.new,
  name: r'loanSelectedTabIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loanSelectedTabIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoanSelectedTabIndex = AutoDisposeNotifier<int>;
String _$loanSortByHash() => r'9f7eff47332265b1d4dcc111408e379c7d614a7d';

/// See also [LoanSortBy].
@ProviderFor(LoanSortBy)
final loanSortByProvider =
    AutoDisposeNotifierProvider<LoanSortBy, String>.internal(
  LoanSortBy.new,
  name: r'loanSortByProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loanSortByHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoanSortBy = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
