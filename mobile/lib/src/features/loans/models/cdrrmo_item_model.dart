/// Model representing a CDRRMO inventory item
class CdrrmoItem {
  final String id;
  final String name;
  final String code;
  final String category;
  final String description;

  const CdrrmoItem({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CdrrmoItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CdrrmoItem{id: $id, name: $name, code: $code, category: $category}';
  }
}