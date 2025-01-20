import 'package:danventory/domain/db/supabase_db.dart';
import 'package:danventory/domain/entities/category_model.dart';
import 'package:danventory/domain/interfaces/icategory_model.dart';

class CategoryRepository implements ICategoryModel {
  final _db = SupabaseDB();
  @override
  Future<String> create(CategoryModel t) async {
    try {
      final response = await _db.client
          .from("categories")
          .insert(t.toMap())
          .select("categoryid")
          .single();
      if (response.isEmpty) {
        throw Exception("Error con el servidor, intente más tarde...");
      }
      return response["categoryid"].toString();
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde... ${e}");
    }
  }

  @override
  Future<bool> delete(CategoryModel t) async {
    try {
      await _db.client
          .from("categories")
          .update({"status": t.status}).eq('categoryid', t.categoryId!);
      return true;
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde...");
    }
  }

  @override
  Future<List<CategoryModel>> read(int readById) async {
    try {
      final response =
          await _db.client.from("categories").select().eq("userId", readById);

      if (response.isEmpty) {
        return [];
      }
      return response
          .map(
            (e) => CategoryModel.fromMap(e),
          )
          .toList();
    } catch (e) {
      throw Exception("Error al consultar todos sus datos");
    }
  }

  @override
  Future<bool> update(CategoryModel t) async {
    try {
      await _db.client
          .from("categories")
          .update(t.toMap())
          .eq('categoryid', t.categoryId!);
      return true;
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde...");
    }
  }
}
