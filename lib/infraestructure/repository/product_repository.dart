import 'dart:io';
import 'dart:typed_data';

import 'package:danventory/domain/db/supabase_db.dart';
import 'package:danventory/domain/entities/product_image.dart';
import 'package:danventory/domain/entities/product_model.dart';
import 'package:danventory/domain/interfaces/iproduct_model.dart';

class ProductRepository implements IProductModel {
  final _db = SupabaseDB();
  @override
  Future<String> create(ProductModel t) async {
    try {
      final response = await _db.client
          .from("products")
          .insert(t.toMap())
          .select("productid")
          .single();
      if (response.isEmpty) {
        throw Exception("Error con el servidor, intente más tarde...");
      }
      return response["productid"].toString();
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde... $e");
    }
  }

  @override
  Future<bool> delete(ProductModel t) async {
    try {
      await _db.client
          .from("products")
          .update({"status": t.status}).eq('productid', t.productId);
      return true;
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde...");
    }
  }

  @override
  Future<bool> deleteImage(ProductImageModel productImageModel) async {
    try {
      await _db.client
          .from("products")
          .delete()
          .eq('productid', productImageModel.productImageId);
      return true;
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde...");
    }
  }

  @override
  Future<List<ProductModel>> read(int userId) async {
    try {
      final response = await _db.client.rpc('get_products_with_single_image',
          params: {'user_id_param': userId});

      final data = response as List;
      return data.map((item) => ProductModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception("${e}");
    }
  }

  @override
  Future<bool> update(ProductModel t) async {
    try {
      await _db.client
          .from("products")
          .update(t.toMap())
          .eq('productid', t.productId);
      return true;
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde...");
    }
  }

  @override
  Future<String> saveImage(int productId, List<File> images) async {
    String url = "";
    try {
      final storage = _db.client.storage;
      for (int i = 0; i < images.length; i++) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${images[i].path.split('/').last}';

        await storage.from('ProductImages').upload(fileName, images[i]);

        final imageUrl =
            await storage.from('ProductImages').getPublicUrl(fileName);

        final insertResponse = await _db.client
            .from('productimages')
            .insert({
              'productid': productId,
              'url': imageUrl,
            })
            .select("productimageid")
            .single();
        if (i == 0) {
          url = imageUrl;
        }
        if (insertResponse.isEmpty) {
          throw Exception("Error con el servidor, intente más tarde...");
        }
      }
      return url;
    } catch (e) {
      throw Exception('Error al guardar la imagen: $e');
    }
  }

  @override
  Future<List<ProductImageModel>> readImages(int productId) async {
    try {
      final response = await _db.client
          .from("productimages")
          .select()
          .eq("productid", productId);

      if (response.isEmpty) {
        return [];
      }
      return response
          .map(
            (e) => ProductImageModel.fromMap(e),
          )
          .toList();
    } catch (e) {
      throw Exception("Error al consultar todos sus datos");
    }
  }
}
