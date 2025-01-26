import 'package:danventory/domain/entities/category_model.dart';
import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:danventory/ui/widgets/choice_chip_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ListTileWidgetCategory extends StatelessWidget {
  final CategoryModel categoryModel;

  const ListTileWidgetCategory({super.key, required this.categoryModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                categoryModel.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                width: 3,
              ),
              ChoiceChipWidget(isActive: categoryModel.status ?? false)
            ]),
        subtitle: Text(
          categoryModel.description!,
          style: const TextStyle(color: ThemeSetting.borderColor),
        ));
  }
}
