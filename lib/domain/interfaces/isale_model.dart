
import 'package:danventory/domain/entities/sale_model.dart';
import 'package:danventory/domain/interfaces/imodel.dart';

abstract class ISaleModel extends IModel<SaleModel>{
  Future<String> createSales(List<SaleModel> t); 
}
