import 'package:danventory/domain/db/supabase_db.dart';
import 'package:danventory/domain/entities/sale_model.dart';

import 'package:danventory/domain/interfaces/isale_model.dart';

class SaleRepository implements ISaleModel {
  final _db = SupabaseDB();
  @override
  Future<String> create(SaleModel t) async {
    try {
      final response = await _db.client
          .from("sales")
          .insert(t.toMap())
          .select("saleid")
          .single();
      if (response.isEmpty) {
        throw Exception("Error con el servidor, intente más tarde...");
      }
      return response["saleid"].toString();
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde... $e");
    }
  }

  @override
  Future<bool> delete(SaleModel t) async {
    try {
      await _db.client
          .from("sales")
          .update({"status": t.status}).eq('saleid', t.saleId);
      return true;
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde...");
    }
  }

  @override
  Future<List<SaleModel>> read(int readById) async {
    try {
      final response =
          await _db.client.from("sales").select().eq("orderid", readById);

      if (response.isEmpty) {
        return [];
      }
      return response
          .map(
            (e) => SaleModel.fromMap(e),
          )
          .toList();
    } catch (e) {
      throw Exception("Error al consultar todos sus datos");
    }
  }

  @override
  Future<bool> update(SaleModel t) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<String> createSales(List<SaleModel> t) async {
    try {
      await _db.client.from("sales").upsert(t.map((e) => e.toMap()).toList());

      return "Succefult";
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde... $e");
    }
  }
}
