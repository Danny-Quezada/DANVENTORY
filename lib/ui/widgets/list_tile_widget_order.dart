import 'package:danventory/domain/entities/order_model.dart';
import 'package:danventory/ui/utils/date_converter.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/choice_chip_widget.dart';

import 'package:flutter/material.dart';

class ListTileWidgetOrder extends StatelessWidget {
  final OrderModel orderModel;

  const ListTileWidgetOrder({super.key, required this.orderModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(children: [
          Text(
            "Fecha: ${DateConverter.formatDateWithMonthName(date: orderModel.orderDate)}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            width: 3,
          ),
          ChoiceChipWidget(isActive: orderModel.status)
        ]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Precios:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text.rich(
              TextSpan(
                text: "Precio de compra: ",
                children: [
                  TextSpan(
                    text: "${orderModel.purchasePrice}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ThemeSetting.principalColor),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Precio de venta: ",
                children: [
                  TextSpan(
                    text: "${orderModel.salePrice}  " +
                        "(+${calculateProfitPercentage().toStringAsPrecision(3)}%)",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ThemeSetting.greenColor),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Cantidades:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text.rich(
              TextSpan(
                text: "Cantidad comprada: ",
                children: [
                  TextSpan(
                    text: "${orderModel.quantity}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ThemeSetting.principalColor),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "Cantidad actualmente: ",
                children: [
                  TextSpan(
                    text: "${orderModel.remainingQuantity}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: getColor()),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  double calculateProfitPercentage() {
    double profitPercentage =
        100 - (orderModel.purchasePrice / orderModel.salePrice) * 100;
    return profitPercentage;
  }

  Color getColor() {
    if (orderModel.remainingQuantity == orderModel.quantity) {
      return ThemeSetting.principalColor;
    } else if (orderModel.remainingQuantity < orderModel.quantity) {
      return ThemeSetting.greenColor;
    } else {
      return ThemeSetting.redColor;
    }
  }
}
