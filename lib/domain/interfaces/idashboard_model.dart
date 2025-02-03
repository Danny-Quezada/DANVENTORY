import 'package:danventory/domain/entities/dashboard_model.dart';

abstract class IdashboardModel {
  Future<Iterable<SaleByMonth>> getSalesByMonth(int userId);
  Future<Iterable<SaleByCategory>> getSalesByCategory(int userId);
  Future<Iterable<TotalRevenue>> getTotalRevenue(int userId);
  Future<Iterable<TopSelling>> getTopSellingProducts(int userId);
  Future<Iterable<SaleByMonthAndCategory>> getSalesByMonthAndCategory(int userId);
}