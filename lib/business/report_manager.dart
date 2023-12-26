import 'package:neocortexapp/core/cache/cache.dart';
import 'package:neocortexapp/dataaccess/report_repository.dart';
import 'package:neocortexapp/entities/report.dart';

class ReportManager {
  static Future<Report?> getCachedReportData() async {
    var cached = await CacheData.getCachedReport();
    if (cached == null) {
      return ReportRepository.getReport();
    }
    return cached;
  }
}
