class ProductImageModel {
  int productImageId;
  int productId;
  String url;

  ProductImageModel({
    required this.productImageId,
    required this.productId,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'productid': productId,
      'url': url,
    };
  }

  factory ProductImageModel.fromMap(Map<String, dynamic> map) {
    return ProductImageModel(
      productImageId: map['productimageid'],
      productId: map['productid'],
      url: map['url'],
    );
  }
}
