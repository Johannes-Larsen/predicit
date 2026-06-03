import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/market.dart';

class MarketImage extends StatelessWidget {
  const MarketImage({super.key, required this.market, this.fit = BoxFit.contain});

  final Market market;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final String? photoPath = market.photoPath;
    if (photoPath != null && photoPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(photoPath),
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _FallbackIcon(),
        ),
      );
    }

    return SvgPicture.asset(market.imageAsset, fit: fit);
  }
}

class _FallbackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}
