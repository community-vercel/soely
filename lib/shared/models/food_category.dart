import 'package:equatable/equatable.dart';

class FoodCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String icon;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.icon,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        icon,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];

  FoodCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? icon,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'icon': icon,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FoodCategory.fromMap(Map<String, dynamic> map) {
    return FoodCategory(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      icon: map['icon'] ?? '',
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder']?.toInt() ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  factory FoodCategory.fromJson(String source) {
    return FoodCategory.fromMap({});
  }

  String toJson() {
    return toMap().toString();
  }
}