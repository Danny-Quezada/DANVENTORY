class OrderModel {
  int orderid;
  int productid;
  DateTime orderDate;
  int quantity;
  int remainingQuantity;
  double salePrice;
  double purchasePrice;
  bool status;

  OrderModel(
      {required this.orderid,
      required this.productid,
      required this.orderDate,
      required this.quantity,
      required this.remainingQuantity,
      required this.salePrice,
      required this.purchasePrice,
      this.status = true});

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderid: map['orderid'],
      productid: map['productid'],
      orderDate: DateTime.parse(map['order_date']),
      quantity: map['quantity'],
      remainingQuantity: map['remaining_quantity'],
      salePrice: map['sale_price'].toDouble(),
      purchasePrice: map['purchase_price'].toDouble(),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productid': productid,
      'order_date': orderDate.toIso8601String(),
      'quantity': quantity,
      'remaining_quantity': remainingQuantity,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'status': status,
    };
  }
}
