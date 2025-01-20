import 'package:danventory/ui/utils/theme_setting.dart';
import 'package:flutter/material.dart';

class ChoiceChipWidget extends StatelessWidget {
  final bool isActive;
  const ChoiceChipWidget({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
        labelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
        padding: EdgeInsets.zero,
        showCheckmark: false,
        labelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        disabledColor: ThemeSetting.redColor,
        selectedColor: ThemeSetting.greenColor,
        label: Text(
          isActive ? "Activo" : "Inactivo",
          style: const TextStyle(color: Colors.white),
        ),
        selected: isActive);
  }
}
