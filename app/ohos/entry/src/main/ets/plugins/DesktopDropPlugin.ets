import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  FlutterManager,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodChannel
} from '@ohos/flutter_ohos';
import { DocumentPickerPlugin } from './DocumentPickerPlugin';

export function documentUris(records: unifiedDataChannel.UnifiedRecord[]): string[] {
  const uris: string[] = [];
  for (const record of records) {
    const fileUriType = uniformTypeDescriptor.UniformDataType.FILE_URI;
    const uri = (record as unifiedDataChannel.File).uri
      || (record.getTypes().includes(fileUriType) ? record.getEntry(fileUriType) as string : '');
    if (typeof uri === 'string' && uri.startsWith('file://') && !uris.includes(uri)) {
      uris.push(uri);
    }
  }
  return uris;
}

export class DesktopDropPlugin implements FlutterPlugin {
  private channel?: MethodChannel;
  private enterId?: number;
  private leaveId?: number;
  private dropId?: number;
  private documents: DocumentPickerPlugin;

  constructor(documents: DocumentPickerPlugin) {
    this.documents = documents;
  }

  getUniqueClassName(): string {
    return 'LocalSendDesktopDrop';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'org.localsend.localsend_app/harmony_drop');
    const manager = FlutterManager.getInstance();
    this.enterId = manager.addDragEnterCb({
      do: (event: DragEvent): void => {
        event.setResult(DragResult.DROP_ENABLED);
        this.channel?.invokeMethod('dragEntered', null);
      }
    });
    this.leaveId = manager.addDragLeaveCb({
      do: (): void => this.channel?.invokeMethod('dragExited', null)
    });
    this.dropId = manager.addDropCb({
      do: (event: DragEvent): void => {
        this.channel?.invokeMethod('dragExited', null);
        try {
          const uris = documentUris(event.getData().getRecords());
          hilog.info(0x0, 'LocalSendDrop', 'System drop provided %{public}d documents', uris.length);
          if (uris.length === 0) {
            event.setResult(DragResult.DRAG_FAILED);
            return;
          }
          event.setResult(DragResult.DRAG_SUCCESSFUL);
          this.documents.prepareDocuments(uris, true).then((items) => {
            const payload = new Map<string, string[]>();
            payload.set('files', items.files);
            payload.set('folders', items.folders);
            this.channel?.invokeMethod('documentsDropped', payload);
          }).catch(() => {
            hilog.warn(0x0, 'LocalSendDrop', 'Unable to read the dropped documents');
            this.channel?.invokeMethod('dropFailed', null);
          });
        } catch (_) {
          hilog.warn(0x0, 'LocalSendDrop', 'Unable to decode the system drop');
          event.setResult(DragResult.DRAG_FAILED);
          this.channel?.invokeMethod('dropFailed', null);
        }
      }
    });
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    const manager = FlutterManager.getInstance();
    if (this.enterId !== undefined) {
      manager.removeDragEnterCb(this.enterId);
    }
    if (this.leaveId !== undefined) {
      manager.removeDragLeaveCb(this.leaveId);
    }
    if (this.dropId !== undefined) {
      manager.removeDropCb(this.dropId);
    }
    this.channel = undefined;
  }
}
