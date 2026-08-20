import 'package:flutter/material.dart';

class MoviePosterImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color fallbackColor;
  final Color iconColor;
  final double iconSize;

  const MoviePosterImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackColor = const Color.fromARGB(255, 40, 40, 40),
    this.iconColor = Colors.white54,
    this.iconSize = 42,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url ?? '';
    final child = imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (_, __, ___) => _fallback,
          )
        : _fallback;

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget get _fallback => Container(
        height: height,
        width: width,
        color: fallbackColor,
        alignment: Alignment.center,
        child: Icon(
          Icons.local_movies,
          color: iconColor,
          size: iconSize,
        ),
      );
}
