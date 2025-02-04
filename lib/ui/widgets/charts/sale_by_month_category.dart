
import 'package:danventory/domain/entities/dashboard_model.dart';
import 'package:danventory/domain/interfaces/idashboard_model.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/date_converter.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/charts/skeleton_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
              style: ThemeSetting.titleStyle
            ,
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
