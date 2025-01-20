import 'package:flutter/widgets.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  const EmptyWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/add.png"),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
