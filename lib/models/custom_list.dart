class CustomList {
  final String id;
  final String name;
  final List<String> itemImdbIds;

  CustomList({
    required this.id,
    required this.name,
    required this.itemImdbIds,
  });

  factory CustomList.fromJson(Map<String, dynamic> json) {
    return CustomList(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      itemImdbIds: List<String>.from(json['items'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'items': itemImdbIds,
      };
}