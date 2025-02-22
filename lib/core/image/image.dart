import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageSvg extends StatelessWidget {
  final String path;
  final double? height;
  final double? width;

  const ImageSvg(
      {required this.path,
      super.key,
       this.height,
       this.width});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: height,
      width: width,
    );
  }
}
