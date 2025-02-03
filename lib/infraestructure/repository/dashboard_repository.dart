import 'package:danventory/domain/db/supabase_db.dart';
import 'package:danventory/domain/entities/dashboard_model.dart';
import 'package:danventory/domain/interfaces/idashboard_model.dart';

class DashboardRepository implements IdashboardModel {
  final _db = SupabaseDB();

  Future<List<T>> _fetchData<T>(String rpcFunction, int userId,
      T Function(Map<String, dynamic>) fromMap) async {
    try {
      final response =
          await _db.client.rpc(rpcFunction, params: {'user_id': userId});
      final data = response as List;
      return data.map((item) => fromMap(item)).toList();
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<List<SaleByCategory>> getSalesByCategory(int userId) async {
    return await _fetchData(
        'get_sales_by_category', userId, SaleByCategory.fromMap);
  }

  @override
  Future<List<SaleByMonth>> getSalesByMonth(int userId) async {
    return await _fetchData('get_sales_by_month', userId, SaleByMonth.fromMap);
  }

  @override
  Future<List<SaleByMonthAndCategory>> getSalesByMonthAndCategory(
      int userId) async {
    
      return await _fetchData('get_sales_by_month_and_category', userId,
          SaleByMonthAndCategory.fromMap);
     
  
    
  }

  @override
  Future<List<TopSelling>> getTopSellingProducts(int userId) async {
    return await _fetchData(
        'get_top_selling_products', userId, TopSelling.fromMap);
  }

  @override
  Future<List<TotalRevenue>> getTotalRevenue(int userId) async {
    return await _fetchData('get_total_revenue', userId, TotalRevenue.fromMap);
  }
}
