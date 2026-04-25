import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../fast_dispatch/model/dispatch_session.dart';
import '../repositories/personnel_repository.dart';

/// 🚀 Zero-Latency Fuzzy Filtering Provider
/// Critical: Runs locally against cached registry for <1ms response.
/// No code generation used to avoid build_runner dependency in tactical environments.
final personnelSearchControllerProvider = Provider.family<List<BorrowerInfo>, String>((ref, query) {
  final cleanQuery = query.trim().toLowerCase();
  if (cleanQuery.isEmpty) return [];

  final registry = ref.watch(personnelRegistryProvider).value ?? [];
  
  // Weighted Filter:
  // 1. Name or Office matches normalized query
  final results = registry.where((p) {
    final name = p.name.toLowerCase();
    final office = (p.office ?? '').toLowerCase();
    
    // We use contains for fuzzy matching, which supports 1-letter search
    return name.contains(cleanQuery) || office.contains(cleanQuery);
  }).toList();

  // Sort by "Starts With" to keep most relevant on top
  results.sort((a, b) {
    final aStart = a.name.toLowerCase().startsWith(cleanQuery);
    final bStart = b.name.toLowerCase().startsWith(cleanQuery);
    if (aStart && !bStart) return -1;
    if (!aStart && bStart) return 1;
    return a.name.compareTo(b.name);
  });

  return results.take(10).toList();
});
