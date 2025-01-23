import 'dart:io';

import 'package:danventory/domain/entities/category_model.dart';
import 'package:danventory/domain/entities/product_image.dart';
import 'package:danventory/domain/entities/product_model.dart';
import 'package:danventory/domain/interfaces/iproduct_model.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider extends ChangeNotifier {
  String search = "";
  bool isActive = true;
  ProductModel? productModel;
  List<ProductModel> productModels = [];
  List<ProductImageModel> productImageModels = [];
  CategoryModel? category;

  set setCategory(category) {
    this.category = category;
    notifyListeners();
  }

  List<XFile> images = [];

  set setImages(List<XFile> images) {
    this.images = images;
    notifyListeners();
  }

  deleteImageFile(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  IProductModel iProductModel;
  ProductProvider({required this.iProductModel});

  Future<void> create(ProductModel t, List<File> images) async {
    try {
      final response = await iProductModel.create(t);
      if (response.isNotEmpty) {
        t.productId = int.parse(response);
        final isSave = await iProductModel.saveImage(t.productId, images);
        t.image = isSave;
        productModels.add(t);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(ProductModel t) async {
    try {
      final isDelete = await iProductModel.delete(t);
      if (isDelete) {
        int index =
            productModels.indexWhere((item) => item.productId == t.productId);
        if (index != -1) {
          productModels[index].status = t.status;
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> read(int readById) async {
    try {
      productModels = await iProductModel.read(readById);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(ProductModel t) async {
    try {
      final bool isUpdate = await iProductModel.update(t);
      if (isUpdate) {
        int index =
            productModels.indexWhere((item) => item.productId == t.productId);
        if (index != -1) {
          productModels[index] = t;
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImage(ProductImageModel productImageModel) async {
    try {
      final isDelete = await iProductModel.deleteImage(productImageModel);
      if (isDelete) {
        int index = productImageModels.indexWhere(
            (item) => item.productImageId == productImageModel.productImageId);
        if (index != -1) {
          productModels.removeAt(index);
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveImage(int productId, List<File> images) async {
    try {
      await iProductModel.saveImage(productId, images);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> readImages(int productId) async {
    try {
      productImageModels = await iProductModel.readImages(productId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void changeDrop() {
    isActive = !isActive;
    notifyListeners();
  }

  void searchFind(String word) {
    search = word;
    notifyListeners();
  }
}
