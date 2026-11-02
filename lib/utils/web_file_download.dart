import 'web_file_download_stub.dart'
    if (dart.library.html) 'web_file_download_web.dart';

Future<bool> downloadFileOnWeb({
  required List<int> bytes,
  required String filename,
  String mimeType = 'image/png',
}) {
  return triggerWebFileDownload(
    bytes: bytes,
    filename: filename,
    mimeType: mimeType,
  );
}
