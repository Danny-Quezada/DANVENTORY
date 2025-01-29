import 'package:danventory/domain/entities/sale_model.dart';
import 'package:danventory/ui/utils/date_converter.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/choice_chip_widget.dart';

import 'package:flutter/material.dart';

class ListTileWidgetSales extends StatelessWidget {
  final SaleModel saleModel;

  const ListTileWidgetSales({super.key, required this.saleModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Fecha: ${DateConverter.formatDateWithMonthName(date: saleModel.saleDate)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                width: 3,
              ),
              ChoiceChipWidget(isActive: saleModel.status)
            ]),
        subtitle: Text.rich(
          TextSpan(
            text: "Cantidad: ",
            children: [
              TextSpan(
                text: "${saleModel.quantity}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ThemeSetting.principalColor),
              ),
            ],
          ),
          style: const TextStyle(color: ThemeSetting.borderColor),
        ));
  }
}
