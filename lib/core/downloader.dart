part of '../media_cache_manager.dart';

class Downloader {
  Downloader({required this.url});

  final String url;
  final CancelToken _cancelToken = CancelToken();
  final Dio _dio = Dio();

  Future<String?> download({
    required Function(int progress, int total) onProgress,
    void Function()? cancelDownload,
  }) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      await _dio.download(
        url,
        '${downloadDir.path}/${url.hashCode}',
        onReceiveProgress: onProgress,
        cancelToken: _cancelToken,
      );
      final filePath = '${downloadDir.path}/${url.hashCode}';
      return filePath;
    } catch (e, s) {
      customLog(e.toString(), s);
      return null;
    }
  }

  Future<void> cancel() async {
    try {
      if (!_cancelToken.isCancelled) {
        _cancelToken.cancel();
      }
    } catch (e, s) {
      customLog(e.toString(), s);
    }
  }

  static Future<Directory> _getDownloadDirectory() async {
    final appDir = await getTemporaryDirectory();
    final downloadDir = Directory(appDir.path);
    final isDirExist = await downloadDir.exists();
    if (!isDirExist) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  static Future<void> clearCachedFiles() async {
    final dir = await _getDownloadDirectory();
    await dir.delete(recursive: true);
  }
}
