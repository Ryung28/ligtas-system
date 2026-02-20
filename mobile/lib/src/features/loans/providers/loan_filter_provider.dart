import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_filter.dart';

class LoanFilterNotifier extends Notifier<LoanFilter> {
  @override
  LoanFilter build() {
    return const LoanFilter();
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void updateSort(LoanSortOption sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = const LoanFilter();
  }
}

final loanFilterProvider = NotifierProvider<LoanFilterNotifier, LoanFilter>(
  LoanFilterNotifier.new,
);
