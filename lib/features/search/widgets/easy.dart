import 'package:event/core/image/image.dart';
import 'package:flutter/material.dart';

class Easy extends StatelessWidget {
  final Color color;
  final String path;

  final String text;
  const Easy({
    super.key,
    required this.color,
    required this.path,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(3),
      child: Column(
        children: [
          ImageSvg(
            height: 100,
            width: 100,
            path: path,
          ),
          const SizedBox(height: 10), // Space between image and text
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
