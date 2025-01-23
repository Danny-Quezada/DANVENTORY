class ProductModel {
  int productId;
  int categoryId;
  String productName;
  String description;
  int quantity;
  bool status;
  int userId;
  String? image;
  String? categoryName;
  ProductModel(
      {required this.productId,
      required this.categoryId,
      required this.productName,
      required this.description,
      required this.quantity,
      required this.status,
      required this.userId,
      this.image,
      this.categoryName});

  Map<String, dynamic> toMap() {
    return {
      'categoryid': categoryId,
      'product_name': productName,
      'description': description,
      'status': status,
      'userId': userId,
      'quantity': quantity,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productid'],
      categoryId: map['categoryid'],
      productName: map['product_name'],
      description: map['description'],
      quantity: map['quantity'],
      status: map['status'],
      userId: map['userid'],
      image: map['image_url'],
      categoryName: map['category_name'],
    );
  }
}
