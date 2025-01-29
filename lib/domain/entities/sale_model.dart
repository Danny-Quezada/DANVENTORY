class SaleModel {
  int saleId;
  int orderId;
  DateTime saleDate;
  int quantity;
  bool status;

  SaleModel({
    required this.saleId,
    required this.orderId,
    required this.saleDate,
    required this.quantity,
    this.status = true,
  });

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      saleId: map['saleid'] as int,
      orderId: map['orderid'] as int,
      saleDate: DateTime.parse(map['sale_date'] as String),
      quantity: map['quantity'] as int,
      status: map['status'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderid': orderId,
      'sale_date': saleDate.toIso8601String(),
      'quantity': quantity,
      'status': status,
    };
  }
}
