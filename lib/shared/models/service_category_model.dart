class ServiceCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String type; // 'MOVILIDAD' | 'DELIVERY'
  final String? icon;
  final int sortOrder;
  final bool isActive;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.type,
    this.icon,
    required this.sortOrder,
    required this.isActive,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'MOVILIDAD',
      icon: json['icon'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}