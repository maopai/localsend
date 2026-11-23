
import { window } from '@kit.ArkUI';
import { FlutterAbility, FlutterEngine, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { ConnectivityPlugin } from '../plugins/ConnectivityPlugin';
import { DocumentPickerPlugin } from '../plugins/DocumentPickerPlugin';
import { DesktopDropPlugin } from '../plugins/DesktopDropPlugin';
import { pickClipboard } from '../plugins/ClipboardPicker';
import { StatusTray } from '../plugins/StatusTray';
import { BusinessError } from '@kit.BasicServicesKit';
import { PackageInfoPlugin } from '../plugins/PackageInfoPlugin';

export default class EntryAbility extends FlutterAbility {
  private appWindow?: window.Window;
  private statusTray?: StatusTray;

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    flutterEngine.getPlugins()?.add(new ConnectivityPlugin());
    const documents = new DocumentPickerPlugin(this.context);
    flutterEngine.getPlugins()?.add(documents);
    flutterEngine.getPlugins()?.add(new DesktopDropPlugin(documents));
    flutterEngine.getPlugins()?.add(new PackageInfoPlugin());
    const channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),
      'org.localsend.localsend_app/harmony_window');
    channel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult): void => {
        const appWindow = this.appWindow;
        if (!appWindow) {
          result.error('NO_WINDOW', 'LocalSend window is unavailable', null);
          return;
        }
        if (call.method === 'pickClipboard') {
          pickClipboard(appWindow.getUIContext(), documents, call.args as string).then((selection) => {
            result.success(selection);
          }).catch(() => result.error('CLIPBOARD', 'Unable to read the clipboard', null));
          return;
        }
        let operation: Promise<void> | undefined;
        switch (call.method) {
          case 'keepScreenOn':
            operation = appWindow.setWindowKeepScreenOn(call.args === true);
            break;
          case 'initTray': {
            const args = call.args as Map<string, string | boolean>;
            if (this.statusTray) {
              this.statusTray.minimizeOnClose = args.get('minimizeOnClose') === true;
              operation = this.statusTray.install(args.get('open') as string, args.get('close') as string);
            }
            break;
          }
          case 'setMinimizeOnClose':
            if (this.statusTray) {
              this.statusTray.minimizeOnClose = call.args === true;
              operation = Promise.resolve();
            }
            break;
          case 'showWindow':
            operation = this.statusTray?.show();
            break;
          default:
            result.notImplemented();
            return;
        }
        if (!operation) {
          result.error('NO_WINDOW', 'LocalSend window is unavailable', null);
          return;
        }
        operation.then(() => result.success(null))
          .catch((error: BusinessError) => result.error('HARMONY_WINDOW', error.message, error.code));
      }
    });
  }

  onWindowStageCreate(stage: window.WindowStage): void {
    this.appWindow = stage.getMainWindowSync();
    this.statusTray = new StatusTray(this.context, this.appWindow);
    super.onWindowStageCreate(stage);
  }

  onWindowStageDestroy(): void {
    this.statusTray?.dispose();
    this.statusTray = undefined;
    this.appWindow = undefined;
    super.onWindowStageDestroy();
  }
}
