import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? assetFallback;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.assetFallback,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl.isEmpty) {
      imageWidget = _buildFallback(context);
    } else if (imageUrl.startsWith('assets/')) {
      // Local bundled asset
      imageWidget = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (assetFallback != null && assetFallback != imageUrl) {
            return Image.asset(
              assetFallback!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, _, _) => _buildFallback(context),
            );
          }
          return _buildFallback(context);
        },
      );
    } else {
      // Remote network image with local asset fallback support
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.warmCream,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.forestGreen,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (assetFallback != null) {
            return Image.asset(
              assetFallback!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, _, _) => _buildFallback(context),
            );
          }
          return _buildFallback(context);
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.mutedSage : AppColors.forestGreen;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.warmCream;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: (isDark ? AppColors.dividerDark : AppColors.mutedSage)
              .withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.forestGreen : AppColors.mutedSage)
                    .withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.landscape_rounded,
                size: 24,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore India',
              style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
