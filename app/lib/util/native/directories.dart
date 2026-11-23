// Modified for HarmonyOS PC in this fork.

import 'dart:io' show Directory, Platform;

import 'package:flutter/foundation.dart';
import 'package:localsend_app/util/native/channel/android_channel.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:path_provider/path_provider.dart' as path;

Future<String> getDefaultDestinationDirectory() async {
  if (checkPlatformIsHarmonyOS()) {
    // A public directory needs a user grant. The app's documents directory is
    // writable before the user selects a destination.
    return (await path.getApplicationDocumentsDirectory()).path;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return await getDownloadsDirectoryAndroid() ?? '/storage/emulated/0/Download';
    case TargetPlatform.iOS:
      return (await path.getApplicationDocumentsDirectory()).path;
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    default:
      var downloadDir = await path.getDownloadsDirectory();
      if (downloadDir == null) {
        if (defaultTargetPlatform == TargetPlatform.windows) {
          downloadDir = Directory('${Platform.environment['HOMEPATH']}/Downloads');
          if (!downloadDir.existsSync()) {
            downloadDir = Directory(Platform.environment['HOMEPATH']!);
          }
        } else {
          downloadDir = Directory('${Platform.environment['HOME']}/Downloads');
          if (!downloadDir.existsSync()) {
            downloadDir = Directory(Platform.environment['HOME']!);
          }
        }
      }
      return downloadDir.path.replaceAll('\\', '/');
  }
}

Future<String> getCacheDirectory() async {
  final dir = await path.getTemporaryDirectory();
  await dir.create(recursive: true);
  return dir.path;
}
