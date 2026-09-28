import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MapNavigationLauncher {
  static Uri googleMapsUri({required double latitude, required double longitude, String? address}) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude${address != null && address.isNotEmpty ? '&destination_place_id=${Uri.encodeComponent(address)}' : ''}',
    );
  }

  static Uri wazeUri({required double latitude, required double longitude}) {
    return Uri.parse('https://waze.com/ul?ll=$latitude,$longitude&navigate=yes');
  }

  static Uri appleMapsUri({required double latitude, required double longitude, String? name}) {
    return Uri.parse(
      'https://maps.apple.com/?daddr=$latitude,$longitude${name != null ? '&q=${Uri.encodeComponent(name)}' : ''}',
    );
  }

  static Future<void> showNavigationSheet(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String spaceName,
    String? address,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.directions_rounded, color: colors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Navigate to Parking',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            spaceName,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F0FE),
                    child: Icon(Icons.map_rounded, color: Color(0xFF1A73E8)),
                  ),
                  title: const Text(
                    'Google Maps',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Open turn-by-turn route directions'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final uri = googleMapsUri(
                      latitude: latitude,
                      longitude: longitude,
                      address: address,
                    );
                    await _launch(context, uri);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.navigation_rounded, color: Color(0xFF00A0DC)),
                  ),
                  title: const Text(
                    'Waze',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Live traffic and police/hazard alerts'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final uri = wazeUri(latitude: latitude, longitude: longitude);
                    await _launch(context, uri);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF3F4F6),
                    child: Icon(Icons.explore_rounded, color: Color(0xFF374151)),
                  ),
                  title: const Text(
                    'Apple Maps / System Map',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Open in default system navigation app'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final uri = appleMapsUri(
                      latitude: latitude,
                      longitude: longitude,
                      name: spaceName,
                    );
                    await _launch(context, uri);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF1F5F9),
                    child: Icon(Icons.copy_rounded, color: Color(0xFF475569)),
                  ),
                  title: const Text(
                    'Copy Coordinates',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('$latitude, $longitude'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Clipboard.setData(ClipboardData(text: '$latitude, $longitude'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Coordinates ($latitude, $longitude) copied to clipboard.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      final can = await canLaunchUrl(uri);
      if (can) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to launch navigation: $uri'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
