// Modified for HarmonyOS PC in this fork.

import 'package:flutter/foundation.dart';

extension TargetPlatformExt on TargetPlatform {
  String get humanName {
    switch (this) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      default:
        return name == 'ohos' ? 'HarmonyOS' : '${name[0].toUpperCase()}${name.substring(1)}';
    }
  }
}
