import 'package:danventory/domain/entities/dashboard_model.dart';
import 'package:danventory/domain/interfaces/idashboard_model.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/date_converter.dart';
import 'package:danventory/ui/utils/regression.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/amount_container_widget.dart';
import 'package:danventory/ui/widgets/charts/skeleton_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

double calculateProfitPercentage(double purchasePrice, double salePrice) {
  double profitPercentage = 100 - (purchasePrice / salePrice) * 100;
  return profitPercentage;
}

class SaleByMonthWidget extends StatelessWidget {
  const SaleByMonthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return FutureBuilder<Iterable<SaleByMonth>>(
      future: Provider.of<IdashboardModel>(context, listen: false)
          .getSalesByMonth(userProvider.userModel!.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonView();
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        // Obtener los datos de ventas por mes
        List<SaleByMonth> salesData = snapshot.data!.toList();

        // Calcular totales
        int totalQuantity =
            salesData.fold<int>(0, (sum, element) => sum + element.quantity);
        double totalSalesAmount = salesData.fold<double>(
            0.0, (sum, element) => sum + element.totalSalesAmount);
        double totalPurchaseAmount = salesData.fold<double>(
            0.0, (sum, element) => sum + element.totalPurchaseAmount);
        int totalSales =
            salesData.fold<int>(0, (sum, element) => sum + element.totalSales);

       
        final regression = LinearRegression<SaleByMonth>(
          getX: (sale) => sale.monthNumber.toDouble(),
          getY: (sale) => sale.totalSalesAmount,
        ).calculate(salesData);
        final regressionQuantity = LinearRegression<SaleByMonth>(
          getX: (sale) => sale.monthNumber.toDouble(),
          getY: (sale) => sale.quantity.toDouble(),
        ).calculate(salesData);
     
        final predictedMonthNumber = salesData.last.monthNumber + 1 > 12
            ? 1
            : salesData.last.monthNumber + 1; // Manejar el cambio de año
        final predictedSalesAmount = regression.predict(salesData.length + 1);
        final predictedQuantity =
            regressionQuantity.predict(salesData.length + 1);
   
        final predictedMonth = SaleByMonth(
            monthNumber: predictedMonthNumber,
            totalSales: (regression.predict(salesData.length + 1)).round(),
            totalSalesAmount: predictedSalesAmount,
            totalPurchaseAmount: regression.predict(salesData.length + 1),
            quantity: predictedQuantity.toInt());


        List<SaleByMonth> dataWithPrediction = [...salesData, predictedMonth];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
     
            Row(
              children: [
                Expanded(
                  child: AmountContainerWidget(
                    amount: totalSalesAmount,
                    title: "Ventas totales",
                    color: ThemeSetting.greenColor,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: AmountContainerWidget(
                    amount: totalPurchaseAmount,
                    title: "Compras totales",
                    color: ThemeSetting.principalColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: AmountContainerWidget(
                    amount: totalSales,
                    title: "Cantidades de ventas",
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: AmountContainerWidget(
                    amount: totalQuantity,
                    title: "Productos vendidos",
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Ventas por mes",
                style: ThemeSetting.titleStyle,
              ),
            ),

            SfCartesianChart(
              zoomPanBehavior: ZoomPanBehavior(
                enablePinching: true,
                enablePanning: true,
                enableDoubleTapZooming: true,
                enableSelectionZooming: true,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  final saleData = data as SaleByMonth;
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Mes: ${DateConverter.monthNames[saleData.monthNumber - 1]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            "Monto en compra: \$${saleData.totalPurchaseAmount.toStringAsFixed(2)}"),
                        Text(
                            "Ganancias porcentual: ${calculateProfitPercentage(saleData.totalPurchaseAmount, saleData.totalSalesAmount).toStringAsFixed(2)}%"),
                        Text("Cantidades vendidas: ${saleData.quantity}"),
                      ],
                    ),
                  );
                },
              ),
              primaryXAxis: const CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
              ),
              series: <CartesianSeries>[
                LineSeries<SaleByMonth, String>(
                  name: 'Monto Total de Ventas',
                  dataSource: dataWithPrediction,
                  xValueMapper: (SaleByMonth data, _) =>
                      DateConverter.monthNames[data.monthNumber - 1],
                  yValueMapper: (SaleByMonth data, _) => data.totalSalesAmount,
                  markerSettings: const MarkerSettings(isVisible: true),
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  color: ThemeSetting.principalColor,
                  // Cambiar el color del último punto (predicción) a verde
                  pointColorMapper: (SaleByMonth data, _) =>
                      data.monthNumber == predictedMonthNumber
                          ? ThemeSetting.greenColor
                          : ThemeSetting.principalColor,
                ),
              ],
            ),
            const Text.rich(
              style: TextStyle(fontSize: 14),
              TextSpan(text: "El circulo ", children: [
                TextSpan(
                    text: "verde",
                    style: TextStyle(
                        color: ThemeSetting.greenColor,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: " representa una predicción usando regresión lineal.")
              ]),
            )
          ],
        );
      },
    );
  }
}