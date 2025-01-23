import 'dart:io';

import 'package:danventory/domain/entities/product_image.dart';
import 'package:danventory/domain/entities/product_model.dart';
import 'package:danventory/domain/interfaces/imodel.dart';

abstract class IProductModel extends IModel<ProductModel> {
  Future<String> saveImage(int productId, List<File> images);
  Future<bool> deleteImage(ProductImageModel productImageModel);
  Future<List<ProductImageModel>> readImages(int productId);
}
