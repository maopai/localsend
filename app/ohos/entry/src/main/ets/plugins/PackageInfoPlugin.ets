import { bundleManager } from '@kit.AbilityKit';
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult
} from '@ohos/flutter_ohos';

export class PackageInfoPlugin implements FlutterPlugin, MethodCallHandler {
  private binding: FlutterPluginBinding | null = null;
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return 'LocalSendPackageInfo';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.binding = binding;
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'dev.fluttercommunity.plus/package_info');
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    this.binding = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method !== 'getAll') {
      result.notImplemented();
      return;
    }

    try {
      const info = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const manager = this.binding?.getApplicationContext().resourceManager;
      const values = new Map<string, string>();
      values.set('appName', manager?.getStringSync(info.appInfo.labelId) ?? 'LocalSend');
      values.set('packageName', info.name);
      values.set('version', info.versionName);
      values.set('buildNumber', info.versionCode.toString());
      result.success(values);
    } catch (error) {
      result.error('PACKAGE_INFO', 'Unable to read LocalSend package information', null);
    }
  }
}
