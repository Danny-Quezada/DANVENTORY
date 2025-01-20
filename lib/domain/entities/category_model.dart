class CategoryModel {
  int? categoryId;
  String name;
  String? description;
  bool? status;
  int? userId;

  CategoryModel({
    this.categoryId = 0,
    required this.name,
    this.description,
    this.status = true,
    this.userId,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map['categoryid'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      status: map['status'] as bool?,
      userId: map['userId'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'userId': userId,
    };
  }
}
