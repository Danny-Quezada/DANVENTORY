import 'package:danventory/domain/entities/dashboard_model.dart';
import 'package:danventory/domain/interfaces/idashboard_model.dart';
import 'package:danventory/providers/user_provider.dart';
import 'package:danventory/ui/utils/date_converter.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/ai_button.dart';
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

        return GestureDetector(
          onTap: () async {
            await aiButton("""
# Análisis de Ventas Mensuales por Categoría

## Datos Clave de Ventas
**Período Analizado:** ${months.map((m) => DateConverter.monthNames[m - 1]).join(', ')}

### Estadísticas Globales
- **Ventas Totales:** \$${salesData.fold(0.0, (sum, e) => sum + e.totalSalesAmount).toStringAsFixed(2)}
- **Compras Totales:** \$${salesData.fold(0.0, (sum, e) => sum + e.totalPurchaseAmount).toStringAsFixed(2)}
- **Margen Bruto Total:** \$${(salesData.fold(0.0, (sum, e) => sum + e.totalSalesAmount) - salesData.fold(0.0, (sum, e) => sum + e.totalPurchaseAmount)).toStringAsFixed(2)}
- **Unidades Totales Vendidas:** ${salesData.fold<int>(0, (sum, e) => sum + e.totalQuantity)}

## Desglose Mensual por Categoría
${months.map((month) {
              final monthName = DateConverter.monthNames[month - 1];
              final categories = processedData[month]!;
              return '''
### $monthName
${categories.entries.map((e) => '- **${e.key}:** \$${e.value.toStringAsFixed(2)} (${salesData.firstWhere((s) => s.monthNumber == month && s.categoryName == e.key).totalQuantity} unidades)').join('\n')}
''';
            }).join('\n')}

- **Categoría Más Rentable:** ${categories.fold({
                  'name': '',
                  'value': 0.0
                }, (curr, cat) {
              final total = salesData.where((s) => s.categoryName == cat).fold(
                  0.0,
                  (sum, e) =>
                      sum + (e.totalSalesAmount - e.totalPurchaseAmount));
              return total > (curr['value']! as num)
                  ? {'name': cat, 'value': total}
                  : curr;
            })['name']}

- **Ratio Inventario/Ventas:** ${(salesData.fold(0.0, (sum, e) => sum + e.totalPurchaseAmount) / salesData.fold(0, (sum, e) => sum + e.totalQuantity)).toStringAsFixed(2)} por unidad

---

## Preguntas Clave para la IA
1. ¿Qué patrones estacionales se observan en las ventas por categoría?
2. ¿Cómo optimizar los inventarios basado en los meses de mayor demanda?
3. ¿Qué categorías tienen los márgenes de ganancia más altos y por qué?
4. ¿Cómo relacionar las campañas de marketing con los picos de ventas mensuales?
5. ¿Qué categorías requieren ajustes de precios según su desempeño?
6. ¿Cómo predecir la demanda para los próximos meses usando estos datos?

---

""", context);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ventas mensuales por categorías",
                style: ThemeSetting.titleStyle,
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
          ),
        );
      },
    );
  }
}
