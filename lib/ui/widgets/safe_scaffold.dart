import 'package:flutter/material.dart';
import "dart:io" show Platform;

class SafeScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final Widget? bottomNavigationBar;

  const SafeScaffold(
      {super.key,
      required this.body,
      this.appBar,
      this.floatingActionButton,
      this.bottomNavigationBar,
      this.padding = const EdgeInsets.all(8.0)});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? SafeArea(
            child: Scaffold(
              appBar: appBar,
              body: Padding(
                padding: padding,
                child: body,
              ),
              floatingActionButton: floatingActionButton,
              bottomNavigationBar: bottomNavigationBar,
            ),
          )
        : Scaffold(
            appBar: appBar,
            body: Padding(
              padding: padding,
              child: body,
            ),
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: bottomNavigationBar,
          );
  }
}
