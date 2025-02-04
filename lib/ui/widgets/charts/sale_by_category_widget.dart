import 'package:danventory/domain/entities/dashboard_model.dart';
import 'package:danventory/domain/interfaces/idashboard_model.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/ai_button.dart';
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

        List<SaleByCategory> salesData = snapshot.data!.toList();

        return GestureDetector(
          onTap: () async {
            await aiButton(message(salesData), context);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text("Ventas por categoría",
                    style: ThemeSetting.titleStyle),
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
                      xValueMapper: (SaleByCategory data, _) =>
                          data.categoryName,
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
                          color:
                              Colors.white, // Mantener contraste con el fondo
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
          ),
        );
      },
    );
  }

  String message(
    List<SaleByCategory> salesData,
  ) {
    return """"
# Resumen de Ventas y Compras

A continuación, se muestra un resumen de las ventas y compras realizadas.

## Ventas por Categoría

${salesData.map((sale) {
      return '''
- **Categoría:** ${sale.categoryName}
  - **Total de Ventas:** ${sale.totalSales}
  - **Monto Total de Ventas:** \$${sale.totalSalesAmount.toStringAsFixed(2)}
''';
    }).join('\n')}


## Preguntas para la IA


1. ¿Cómo puedo mejorar la rentabilidad de mis ventas por categoría?
2. ¿Qué categorías tienen el mayor margen de ganancia?
3. ¿Cómo puedo optimizar las compras para reducir costos?
4. ¿Qué estrategias puedo implementar para aumentar las ventas de productos específicos?
5. ¿Cómo puedo manejar las categorías con bajas ventas?
6. ¿Qué productos son los más vendidos y cómo puedo capitalizar su éxito?
""";
  }
}
