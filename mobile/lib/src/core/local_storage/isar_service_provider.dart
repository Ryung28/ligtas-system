import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../local_storage/isar_service.dart';

part 'isar_service_provider.g.dart';

class IsarServiceWrapper {
  final Isar isar;
  IsarServiceWrapper(this.isar);
}

@riverpod
IsarServiceWrapper isarService(IsarServiceRef ref) {
  return IsarServiceWrapper(IsarService.instance);
}
