import 'dart:math';

import 'package:danventory/domain/entities/dashboard_model.dart';
import 'package:danventory/domain/interfaces/idashboard_model.dart';

import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/date_converter.dart';
import 'package:danventory/ui/utils/regression.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/amount_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SaleByMonthWidget(),
          SizedBox(
            height: 10,
          ),
          SaleByCategoryWidget(),
          SizedBox(
            height: 10,
          ),
          TopSellingWidget(),
          SizedBox(
            height: 10,
          ),
          SaleByMonthAndCategoryWidget()
        ],
      ),
    );
  }
}

double calculateProfitPercentage(double purchasePrice, double salePrice) {
  double profitPercentage = 100 - (purchasePrice / salePrice) * 100;
  return profitPercentage;
}

const TextStyle titleStyle =
    TextStyle(fontWeight: FontWeight.bold, fontSize: 15);

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

        // Calcular la regresión lineal para predecir el próximo mes
        final regression = LinearRegression<SaleByMonth>(
          getX: (sale) => sale.monthNumber.toDouble(),
          getY: (sale) => sale.totalSalesAmount,
        ).calculate(salesData);
        final regressionQuantity = LinearRegression<SaleByMonth>(
          getX: (sale) => sale.monthNumber.toDouble(),
          getY: (sale) => sale.quantity.toDouble(),
        ).calculate(salesData);
        // Obtener el mes predicho
        final predictedMonthNumber = salesData.last.monthNumber + 1 > 12
            ? 1
            : salesData.last.monthNumber + 1; // Manejar el cambio de año
        final predictedSalesAmount = regression.predict(salesData.length + 1);
        final predictedQuantity =
            regressionQuantity.predict(salesData.length + 1);
        // Crear un objeto SaleByMonth para el mes predicho
        final predictedMonth = SaleByMonth(
            monthNumber: predictedMonthNumber,
            totalSales: (regression.predict(salesData.length + 1)).round(),
            totalSalesAmount: predictedSalesAmount,
            totalPurchaseAmount: regression.predict(salesData.length + 1),
            quantity: predictedQuantity.toInt());

        // Agregar el mes predicho a los datos
        List<SaleByMonth> dataWithPrediction = [...salesData, predictedMonth];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar los totales
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
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Ventas por mes",
                style: titleStyle,
              ),
            ),
            const SizedBox(height: 10),
            // Gráfico con predicción
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

class SaleByCategoryWidget extends StatelessWidget {
  const SaleByCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return FutureBuilder<Iterable<SaleByCategory>>(
      future: Provider.of<IdashboardModel>(context, listen: false)
          .getSalesByCategory(userProvider.userModel!.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonView();
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        Iterable<SaleByCategory> salesData = snapshot.data!.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("Ventas por categoría", style: titleStyle),
            ),
            SizedBox(
              height: 500,
              child: SfCircularChart(
                tooltipBehavior: TooltipBehavior(enable: true),
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                margin: EdgeInsets.zero,
                borderWidth: 0,
                series: <CircularSeries>[
                  PieSeries<SaleByCategory, String>(
                    dataSource: salesData.toList(),
                    xValueMapper: (SaleByCategory data, _) => data.categoryName,
                    yValueMapper: (SaleByCategory data, _) =>
                        data.totalSalesAmount,
                    dataLabelMapper: (SaleByCategory data, _) =>
                        "${data.categoryName}\n\$${data.totalSalesAmount.toStringAsFixed(2)}\nVendidas: ${data.totalSales}",
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.inside,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Mantener contraste con el fondo
                      ),
                      useSeriesColor:
                          true, // Usa el color del sector para el texto
                    ),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class TopSellingWidget extends StatelessWidget {
  const TopSellingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return FutureBuilder<Iterable<TopSelling>>(
      future: Provider.of<IdashboardModel>(context, listen: false)
          .getTopSellingProducts(userProvider.userModel!.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonView();
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        Iterable<TopSelling> topSellings = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cantidades vendidas de cada producto",
              style: titleStyle,
            ),
            SfCartesianChart(
              primaryXAxis: const CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: const NumericAxis(
                majorGridLines: MajorGridLines(width: 0),
                majorTickLines: MajorTickLines(size: 0),
              ),
              series: <CartesianSeries<TopSelling, String>>[
                BarSeries<TopSelling, String>(
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    labelAlignment: ChartDataLabelAlignment.middle,
                  ),
                  dataSource: topSellings.toList(),
                  xValueMapper: (data, _) => data.productName,
                  yValueMapper: (data, _) => data.totalSalesAmount,
                  pointColorMapper: (data, _) =>
                      Colors.accents[Random().nextInt(Colors.accents.length)],
                )
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                canShowMarker: false,
                header: '',
              ),
            )
          ],
        );
      },
    );
  }
}

class SaleByMonthAndCategoryWidget extends StatelessWidget {
  const SaleByMonthAndCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return FutureBuilder<Iterable<SaleByMonthAndCategory>>(
      future: Provider.of<IdashboardModel>(context, listen: false)
          .getSalesByMonthAndCategory(userProvider.userModel!.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonView();
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        Iterable<SaleByMonthAndCategory> salesData = snapshot.data!;
        Map<int, Map<String, double>> processedData = {};

        for (var sale in salesData) {
          processedData.putIfAbsent(sale.monthNumber, () => {});
          processedData[sale.monthNumber]![sale.categoryName] =
              sale.totalSalesAmount;
        }

        List<String> categories =
            salesData.map((e) => e.categoryName).toSet().toList();
        List<int> months = processedData.keys.toList()..sort();

        List<StackedLineSeries<Map<String, dynamic>, String>> seriesList =
            categories.map((category) {
          List<Map<String, dynamic>> categoryData = months.map((month) {
            return {
              'month': DateConverter.monthNames[month - 1],
              'salesAmount': processedData[month]?[category] ?? 0,
            };
          }).toList();

          return StackedLineSeries<Map<String, dynamic>, String>(
            dataSource: categoryData,
            xValueMapper: (data, _) => data['month'] as String,
            yValueMapper: (data, _) => data['salesAmount'] as double,
            name: category,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            enableTooltip: true,
            markerSettings: const MarkerSettings(isVisible: true),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ventas mensuales por categorías",
              style: titleStyle,
            ),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(title: AxisTitle(text: '')),
                legend: const Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(
                    enable: true, header: '', canShowMarker: true),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  enableSelectionZooming: true,
                ),
                series: seriesList,
              ),
            ),
          ],
        );
      },
    );
  }
}

class SkeletonView extends StatelessWidget {
  const SkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
        child: SingleChildScrollView(
      child: Column(
        children: [
          SkeletonParagraph(
            style: const SkeletonParagraphStyle(lines: 1),
          ),
          const SkeletonAvatar(
            style: SkeletonAvatarStyle(height: 300, width: double.infinity),
          ),
        ],
      ),
    ));
  }
}
