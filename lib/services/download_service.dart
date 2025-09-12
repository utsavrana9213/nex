import 'package:Wow/services/api_service.dart';
import 'package:Wow/utils/utils.dart';

class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();

  /// Triggers server-side reel download and returns response map
  Future<Map<String, dynamic>> downloadReel({required String id}) async {
    try {
      final res = await ApiService.downloadReel(id);
      return res;
    } catch (e) {
      Utils.showLog('downloadReel error: $e');
      rethrow;
    }
  }
}



