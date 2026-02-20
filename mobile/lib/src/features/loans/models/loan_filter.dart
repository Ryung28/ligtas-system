import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan_filter.freezed.dart';

@freezed
class LoanFilter with _$LoanFilter {
  const factory LoanFilter({
    @Default('') String query,
    @Default(LoanSortOption.newest) LoanSortOption sortBy,
  }) = _LoanFilter;
}

enum LoanSortOption {
  newest,
  oldest,
  alphabetical,
}
