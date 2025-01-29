import 'package:danventory/domain/entities/order_model.dart';
import 'package:danventory/domain/entities/sale_model.dart';
import 'package:danventory/domain/enums/stock_management_enum.dart';
import 'package:danventory/domain/interfaces/iorder_model.dart';
import 'package:flutter/cupertino.dart';

class OrderProvider with ChangeNotifier {
  IOrderModel iOrderModel;
  OrderProvider({required this.iOrderModel});

  bool isActive = true;
  bool isRemainingQuantity = true;
  List<OrderModel> orderModels = [];
  List<DateTime?> dates = [];
  StockManagementEnum stockManagementEnum = StockManagementEnum.fifo;
  Future<void> create(OrderModel t) async {
    try {
      final response = await iOrderModel.create(t);
      if (response.isNotEmpty) {
        t.orderid = int.parse(response);
        orderModels.add(t);
        if (stockManagementEnum == StockManagementEnum.fifo) {
          orderModels.sort((a, b) => a.orderDate.compareTo(b.orderDate));
        } else {
          orderModels.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        }
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void changeDrop() {
    isActive = !isActive;
    notifyListeners();
  }

  void changeRemaingQuantity() {
    isRemainingQuantity = !isRemainingQuantity;
    notifyListeners();
  }

  void addDates(List<DateTime?>? addedDates) {
    dates = addedDates ?? [];
    notifyListeners();
  }

  void changeStock(StockManagementEnum stockManagementEnum) {
    this.stockManagementEnum = stockManagementEnum;

    if (stockManagementEnum == StockManagementEnum.fifo) {
      orderModels.sort((a, b) => a.orderDate.compareTo(b.orderDate));
    } else {
      orderModels.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    }
    notifyListeners();
  }

  Future<void> delete(OrderModel t) async {
    try {
      final isDelete = await iOrderModel.delete(t);
      if (isDelete) {
        int index = orderModels.indexWhere((item) => item.orderid == t.orderid);
        if (index != -1) {
          orderModels[index].status = t.status;
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> read(int readById) async {
    try {
      orderModels = await iOrderModel.read(readById);
      if (stockManagementEnum == StockManagementEnum.fifo) {
        orderModels.sort((a, b) => a.orderDate.compareTo(b.orderDate));
      } else {
        orderModels.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void updateQuantity(int orderId, int quantity, bool status) {
    int index = orderModels.indexWhere((element) => element.orderid == orderId);
    orderModels[index].remainingQuantity = status
        ? orderModels[index].remainingQuantity - quantity
        : orderModels[index].remainingQuantity + quantity;
    notifyListeners();
  }

  void decreaseQuantity(List<SaleModel> saleDetails) {
    saleDetails.forEach((element) {
      int index =
          orderModels.indexWhere((item) => item.orderid == element.orderId);
      orderModels[index].remainingQuantity =
          orderModels[index].remainingQuantity - element.quantity;
    });
    notifyListeners();
  }
}
