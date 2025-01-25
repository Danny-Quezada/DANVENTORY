import 'package:danventory/domain/db/supabase_db.dart';
import 'package:danventory/domain/entities/order_model.dart';
import 'package:danventory/domain/interfaces/iorder_model.dart';

class OrderRepository implements IOrderModel {
  final _db = SupabaseDB();
  @override
  Future<String> create(OrderModel t) async {
    try {
      final response = await _db.client
          .from("orders")
          .insert(t.toMap())
          .select("orderid")
          .single();
      if (response.isEmpty) {
        throw Exception("Error con el servidor, intente más tarde...");
      }
      return response["orderid"].toString();
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde... $e");
    }
  }

  @override
  Future<bool> delete(OrderModel t) async {
    try {
      await _db.client
          .from("orders")
          .update({"status": t.status}).eq('orderid', t.orderid);
      return true;
    } catch (e) {
      throw Exception("Error con el servidor, intente más tarde...");
    }
  }

  @override
  Future<List<OrderModel>> read(int readById) async {
    try {
      final response =
          await _db.client.from("orders").select().eq("productid", readById);

      if (response.isEmpty) {
        return [];
      }
      return response
          .map(
            (e) => OrderModel.fromMap(e),
          )
          .toList();
    } catch (e) {
      throw Exception("Error al consultar todos sus datos");
    }
  }

  @override
  Future<bool> update(OrderModel t) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
