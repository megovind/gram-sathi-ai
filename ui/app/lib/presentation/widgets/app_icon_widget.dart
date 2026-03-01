import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Displays the GramSathi app icon from assets.
class AppIconWidget extends StatelessWidget {
  const AppIconWidget({
    super.key,
    required this.size,
    this.fit = BoxFit.contain,
  });

  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppConstants.appIconAsset,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, __, ___) => Icon(Icons.mic, size: size, color: Colors.white),
    );
  }
}
