import 'dart:convert';
import 'dart:io';

import 'package:biblechamps/services/database.dart';

class DownloadService {
  // force app data download with every update
  Future<bool> isAssetsDownloaded() async {
    if (await File('${DatabaseService().downloadPath}/data.json').exists() &&
        await File('${DatabaseService().downloadPath}/version.json').exists()) {
      // force assets download with app update
      if (DatabaseService().androidVersion ==
          json.decode(File('${DatabaseService().downloadPath}/version.json')
              .readAsStringSync())) {
        return true;
      }
    }

    return false;
  }

  Future loadData() async {
    DatabaseService().updateChampions();
    DatabaseService().updateSettings();

    await DatabaseService().updateApplicationData(json.decode(
        File('${DatabaseService().downloadPath}/data.json')
            .readAsStringSync()));
  }
}
