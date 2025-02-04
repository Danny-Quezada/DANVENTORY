
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class SkeletonView extends StatelessWidget {
  const SkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
        child: SingleChildScrollView(
      child: Column(
        children: [
          SkeletonParagraph(
            style: const SkeletonParagraphStyle(lines: 3),
          ),
          const SkeletonAvatar(
            style: SkeletonAvatarStyle(height: 300, width: double.infinity),
          ),
        ],
      ),
    ));
  }
}
