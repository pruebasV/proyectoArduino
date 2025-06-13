import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class SvgIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color color;

  const SvgIcon({
    super.key,
    required this.assetName,
    this.size = 36,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$assetName.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}