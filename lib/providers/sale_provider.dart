import 'package:danventory/domain/entities/sale_model.dart';

import 'package:danventory/domain/interfaces/isale_model.dart';
import 'package:flutter/cupertino.dart';

class SaleProvider with ChangeNotifier {
  ISaleModel iSaleModel;
  SaleProvider({required this.iSaleModel});

  bool isActive = true;
  List<SaleModel> saleModels = [];
  List<DateTime?> dates = [];
  Future<void> create(SaleModel t) async {
    try {
      final response = await iSaleModel.create(t);
      if (response.isNotEmpty) {
        t.saleId = int.parse(response);
        saleModels.add(t);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createSales(List<SaleModel> t) async {
    try {
      final response = await iSaleModel.createSales(t);
      if (response.isNotEmpty) {
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

  void addDates(List<DateTime?>? addedDates) {
    dates = addedDates ?? [];
    notifyListeners();
  }

  Future<void> delete(SaleModel t) async {
    try {
      final isDelete = await iSaleModel.delete(t);
      if (isDelete) {
        int index = saleModels.indexWhere((item) => item.saleId == t.saleId);
        if (index != -1) {
          saleModels[index].status = t.status;
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> read(int readById) async {
    try {
      saleModels = await iSaleModel.read(readById);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
