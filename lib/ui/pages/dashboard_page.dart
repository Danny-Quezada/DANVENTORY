import 'dart:math';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/charts/sale_by_category_widget.dart';
import 'package:danventory/ui/widgets/charts/sale_by_month_category.dart';
import 'package:danventory/ui/widgets/charts/sale_by_month_widget.dart';
import 'package:danventory/ui/widgets/charts/top_selling_product_widget.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Toca cualquier titulo de gráfico para usar IA DANVENTORY 🤖",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 18,
                color: ThemeSetting.borderColor),
          ),
          SizedBox(
            height: 30,
          ),
          SaleByMonthWidget(),
          SizedBox(
            height: 50,
          ),
          SaleByCategoryWidget(),
          SizedBox(
            height: 50,
          ),
          TopSellingWidget(),
          SizedBox(
            height: 50,
          ),
          SaleByMonthAndCategoryWidget()
        ],
      ),
    );
  }
}
