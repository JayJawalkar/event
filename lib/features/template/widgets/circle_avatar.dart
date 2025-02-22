import 'package:event/core/image/image.dart';
import 'package:flutter/material.dart';

class CircleAvatarExplicit extends StatelessWidget {
  final String path;
  const CircleAvatarExplicit({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        CircleAvatar(
          child: ImageSvg(path: path),
        ),
        Text("Co-Ordinators")
      ],
    );
  }
}
