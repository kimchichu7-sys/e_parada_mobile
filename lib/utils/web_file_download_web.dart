// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

Future<bool> triggerWebFileDownload({
  required List<int> bytes,
  required String filename,
  String mimeType = 'image/png',
}) async {
  try {
    final base64String = base64Encode(bytes);
    final anchor = html.AnchorElement(
      href: 'data:$mimeType;base64,$base64String',
    )
      ..setAttribute('download', filename)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    return true;
  } catch (_) {
    return false;
  }
}
