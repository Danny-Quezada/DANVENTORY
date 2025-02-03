

class SaleByMonth {
  int monthNumber;
  int totalSales;
  double totalSalesAmount;
  double totalPurchaseAmount;
  int quantity;

  SaleByMonth(
      {required this.monthNumber,
      required this.totalSales,
      required this.totalPurchaseAmount,
      required this.totalSalesAmount,
      required this.quantity});

  factory SaleByMonth.fromMap(Map<String, dynamic> map) {
    return SaleByMonth(
        quantity: map['quantity'] as int,
        monthNumber: map['month_number'] as int,
        totalPurchaseAmount: map['total_purchase_amount'] as double,
        totalSalesAmount: map['total_sales_amount'] as double,
        totalSales: map["total_sales_count"] as int);
  }
}

class SaleByCategory {
  String categoryName;
  int totalSales;
  double totalSalesAmount;

  SaleByCategory(
      {required this.categoryName,
      required this.totalSales,
      required this.totalSalesAmount});

  factory SaleByCategory.fromMap(Map<String, dynamic> map) {
    return SaleByCategory(
        categoryName: map["category_name"] as String,
        totalSales: map["total_sales_count"] as int,
        totalSalesAmount: map["total_sales_amount"] as double);
  }
}

class TotalRevenue {
  double totalPurchaseAmount;
  double totalSalesAmount;

  TotalRevenue(
      {required this.totalPurchaseAmount, required this.totalSalesAmount});

  factory TotalRevenue.fromMap(Map<String, dynamic> map) {
    return TotalRevenue(
        totalPurchaseAmount: map["total_purchase_amount"] as double,
        totalSalesAmount: map["total_sales_amount"] as double);
  }
}

class TopSelling {
  String productName;
  int totalSale;
  double totalSalesAmount;

  TopSelling(
      {required this.productName,
      required this.totalSale,
      required this.totalSalesAmount});

  factory TopSelling.fromMap(Map<String, dynamic> map) {
    return TopSelling(
        productName: map["product_name"] as String,
        totalSale: map["total_sales_count"] as int,
        totalSalesAmount: map["total_sales_amount"]);
  }
}

class SaleByMonthAndCategory {
  int monthNumber;
  String categoryName;
  int totalSales;
  double totalPurchaseAmount;
  double totalSalesAmount;
  int totalQuantity;

  SaleByMonthAndCategory(
      {required this.monthNumber,
      required this.categoryName,
      required this.totalSales,
      required this.totalPurchaseAmount,
      required this.totalSalesAmount,
      required this.totalQuantity});

  factory SaleByMonthAndCategory.fromMap(Map<String, dynamic> map) {
    return SaleByMonthAndCategory(
        monthNumber: map["month_number"] as int,
        categoryName: map["category_name"] as String,
        totalSales: map["total_sales_count"] as int,
        totalPurchaseAmount: map["total_purchase_amount"] as double,
        totalSalesAmount: map["total_sales_amount"] as double,
        totalQuantity: map["total_quantity_sold"] as int);
  }
}
