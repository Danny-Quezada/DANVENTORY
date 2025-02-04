import 'dart:math';

import 'package:danventory/domain/entities/dashboard_model.dart';
import 'package:danventory/domain/interfaces/idashboard_model.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/charts/skeleton_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
              style: ThemeSetting.titleStyle,
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
