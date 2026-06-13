import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppDimensions.radiusMd,
    this.placeholderIcon = Icons.image_outlined,
    this.iconSize = AppDimensions.iconXl,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData placeholderIcon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    if (url == null || url!.isEmpty) return _placeholder(radius);

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _shimmer(radius),
        errorWidget: (_, __, ___) => _placeholder(radius),
      ),
    );
  }

  Widget _placeholder(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: radius,
      ),
      child: Icon(placeholderIcon, size: iconSize, color: AppColors.textHint),
    );
  }

  Widget _shimmer(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: radius,
      ),
    );
  }
}
