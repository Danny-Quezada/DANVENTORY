import 'package:cached_network_image/cached_network_image.dart';
import 'package:danventory/domain/entities/product_model.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/choice_chip_widget.dart';

import 'package:flutter/material.dart';

class ListTileWidgetProduct extends StatelessWidget {
  final ProductModel productModel;

  const ListTileWidgetProduct({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        isThreeLine: true,
        trailing: IconButton.filled(
          onPressed: () {},
          icon: const Icon(Icons.add),
          color: Colors.white,
          style: const ButtonStyle().copyWith(
              backgroundColor: const WidgetStatePropertyAll(Colors.black)),
        ),
        leading: productModel.image == null
            ? null
            : CachedNetworkImage(
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                imageUrl: productModel.image!,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
        contentPadding: EdgeInsets.zero,
        title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            productModel.productName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: 3,
          ),
          Text(productModel.status ? "Activo" : "Inactivo",
              style: TextStyle(
                  color: productModel.status
                      ? ThemeSetting.greenColor
                      : ThemeSetting.redColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productModel.description!,
              style: const TextStyle(color: ThemeSetting.borderColor),
            ),
            Text(
              "Cantidad: ${productModel.quantity}",
              style: const TextStyle(
                  color: ThemeSetting.borderColor, fontWeight: FontWeight.bold),
            )
          ],
        ));
  }
}
