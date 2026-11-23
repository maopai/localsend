import { ComponentContent, UIContext } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { documentUris } from './DesktopDropPlugin';
import { DocumentPickerPlugin } from './DocumentPickerPlugin';

interface ClipboardDialogParams {
  cancelLabel: string;
  paste: () => void;
  cancel: () => void;
  onDenied: () => void;
}

@Builder
function clipboardDialog(params: ClipboardDialogParams): void {
  Row({ space: 12 }) {
    Button(params.cancelLabel, { type: ButtonType.Normal })
      .onClick(() => params.cancel())
    PasteButton()
      .onClick((_event: ClickEvent, authorization: PasteButtonOnClickResult) => {
        if (authorization === PasteButtonOnClickResult.SUCCESS) {
          params.paste();
        } else {
          params.onDenied();
        }
      })
  }
  .justifyContent(FlexAlign.Center)
  .padding(20)
  .borderRadius(20)
  .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
}

type ClipboardValue = string | string[] | Uint8Array;

async function readClipboard(documents: DocumentPickerPlugin): Promise<Map<string, ClipboardValue>> {
  const result = new Map<string, ClipboardValue>();
  const board = pasteboard.getSystemPasteboard();
  if (!(await board.hasData())) {
    return result;
  }
  const data = await board.getData();
  const text = data.getPrimaryText();
  if (text) {
    result.set('text', text);
    return result;
  }

  const pixelMap = data.getPrimaryPixelMap();
  if (pixelMap) {
    const packer = image.createImagePacker();
    try {
      const png = await packer.packToData(pixelMap, { format: 'image/png', quality: 100 });
      result.set('image', new Uint8Array(png));
    } finally {
      await packer.release();
      await pixelMap.release();
    }
    return result;
  }

  let uris: string[] = [];
  for (let i = 0; i < data.getRecordCount(); ++i) {
    const record = data.getRecordAt(i);
    if (record.uri && !uris.includes(record.uri)) {
      uris.push(record.uri);
    }
  }
  if (uris.length === 0) {
    const unifiedData = await board.getUnifiedData();
    uris = documentUris(unifiedData.getRecords());
  }
  if (uris.length > 0) {
    const picked = await documents.prepareDocuments(uris, true);
    result.set('files', picked.files);
    result.set('folders', picked.folders);
  }
  return result;
}

export function pickClipboard(context: UIContext, documents: DocumentPickerPlugin, cancelLabel: string):
  Promise<Map<string, ClipboardValue> | null> {
  return new Promise((resolve, reject) => {
    const prompt = context.getPromptAction();
    let handled = false;
    const params: ClipboardDialogParams = {
      cancelLabel: cancelLabel,
      paste: (): void => {
        if (handled) {
          return;
        }
        handled = true;
        readClipboard(documents).then(resolve).catch(reject).finally(close);
      },
      cancel: (): void => {
        resolve(null);
        close();
      },
      onDenied: (): void => {
        reject(new Error('Clipboard access denied'));
        close();
      }
    };
    const content = new ComponentContent(context, wrapBuilder(clipboardDialog), params);
    const close = (): void => {
      prompt.closeCustomDialog(content).catch(() => {});
    };
    prompt.openCustomDialog(content, {
      onDidDisappear: () => {
        if (!handled) {
          resolve(null);
        }
      }
    }).catch(reject);
  });
}
