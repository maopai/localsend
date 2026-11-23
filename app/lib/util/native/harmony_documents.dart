import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/util/native/cross_file_converters.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:refena_flutter/refena_flutter.dart';

const harmonyDocuments = MethodChannel('org.localsend.localsend_app/harmony_documents');

bool isHarmonyDocumentUri(String? destination) => checkPlatformIsHarmonyOS() && destination != null && destination.startsWith('file://');

String destinationDisplayPath(String destination) =>
    isHarmonyDocumentUri(destination) ? Uri.decodeComponent(Uri.parse(destination).path) : destination;

Future<void> activateHarmonyDestination(String? destination) async {
  if (isHarmonyDocumentUri(destination)) {
    await harmonyDocuments.invokeMethod<void>('activateDestination', destination);
  }
}

Future<void> forgetHarmonyDestination(String? destination) async {
  if (isHarmonyDocumentUri(destination)) {
    await harmonyDocuments.invokeMethod<void>('forgetDestination', destination);
  }
}

Future<bool> addHarmonyDocuments(Ref ref, Map<Object?, Object?> documents) async {
  final folders = (documents['folders'] as List?)?.cast<String>() ?? const [];
  final files = (documents['files'] as List?)?.cast<String>() ?? const [];
  final selection = ref.redux(selectedSendingFilesProvider);
  for (final folder in folders) {
    await selection.dispatchAsync(AddDirectoryAction(folder));
  }
  if (files.isNotEmpty) {
    await selection.dispatchAsync(AddFilesAction(files: files.map(XFile.new), converter: CrossFileConverters.convertXFile));
  }
  return folders.isNotEmpty || files.isNotEmpty;
}
