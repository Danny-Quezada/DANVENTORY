import 'package:danventory/domain/entities/order_model.dart';
import 'package:danventory/domain/interfaces/iorder_model.dart';
import 'package:flutter/cupertino.dart';

class OrderProvider with ChangeNotifier{
  IOrderModel iOrderModel;
  OrderProvider({required this.iOrderModel});

  bool isActive = true;
  List<OrderModel> orderModels = [];
  List<DateTime?> dates=[];
  Future<void> create(OrderModel t) async {
    try {
      final response = await iOrderModel.create(t);
      if (response.isNotEmpty) {
        t.orderid = int.parse(response);
        orderModels.add(t);
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
  void addDates(List<DateTime?>? addedDates){
    dates=addedDates ?? [];
    notifyListeners();
  }

  Future<void> delete(OrderModel t) async {
    try {
      final isDelete = await iOrderModel.delete(t);
      if (isDelete) {
        int index = orderModels
            .indexWhere((item) => item.orderid == t.orderid);
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
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  
}