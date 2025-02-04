
import 'package:danventory/domain/entities/dashboard_model.dart';
import 'package:danventory/domain/interfaces/idashboard_model.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/charts/skeleton_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
              child: Text("Ventas por categoría", style: ThemeSetting.titleStyle),
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
