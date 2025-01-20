import 'package:danventory/domain/entities/category_model.dart';
import 'package:danventory/domain/interfaces/icategory_model.dart';
import 'package:flutter/foundation.dart';

class CategoryProvider extends ChangeNotifier {
  String search="";
  bool isActive = true;
  List<CategoryModel> categoryModels = [CategoryModel(name: "Pantalon 👖")];
  ICategoryModel categoryModel;
  CategoryProvider({required this.categoryModel});

  Future<void> create(CategoryModel t) async {
    try {
      final response = await categoryModel.create(t);
      if (response.isNotEmpty) {
        t.categoryId = int.parse(response);
        categoryModels.add(t);
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
  void searchFind(String word){
    search=word;
    notifyListeners();
  }

  Future<void> delete(CategoryModel t) async {
    try {
      final isDelete = await categoryModel.delete(t);
      if (isDelete) {
        int index = categoryModels
            .indexWhere((item) => item.categoryId == t.categoryId);
        if (index != -1) {
          categoryModels[index].status = t.status;
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> read(int readById) async {
    try {
      categoryModels = await categoryModel.read(readById);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(CategoryModel t) async {
    try {
      final bool isUpdate = await categoryModel.update(t);
      if (isUpdate) {
        int index = categoryModels
            .indexWhere((item) => item.categoryId == t.categoryId);
        if (index != -1) {
          categoryModels[index] = t;
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
