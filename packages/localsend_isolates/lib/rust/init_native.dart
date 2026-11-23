import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:localsend_isolates/rust/frb_generated.dart';

Future<void> initializeRustBridge() {
  final library = Platform.operatingSystem == 'ohos' ? ExternalLibrary.open('librust_lib_localsend_app.so') : null;
  return RustLib.init(externalLibrary: library);
}
