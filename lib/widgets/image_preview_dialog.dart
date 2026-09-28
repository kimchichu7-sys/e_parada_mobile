import 'package:flutter/material.dart';
import 'app_network_image.dart';

class ImagePreviewDialog extends StatelessWidget {
  const ImagePreviewDialog({
    super.key,
    required this.imageUrl,
    this.title = 'Parking Area Picture',
  });

  final String imageUrl;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String title = 'Parking Area Picture',
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => ImagePreviewDialog(
        imageUrl: imageUrl,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: SizedBox(
                  width: double.infinity,
                  height: 380,
                  child: AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    loadingWidget: const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    fallbackWidget: const SizedBox(
                      height: 250,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined, color: Colors.white70, size: 48),
                            SizedBox(height: 10),
                            Text(
                              'Unable to load image preview.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
