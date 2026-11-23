import { BusinessError } from '@kit.BasicServicesKit';
import { common, wantConstant } from '@kit.AbilityKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { fileIo, fileShare, fileUri, picker } from '@kit.CoreFileKit';
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult
} from '@ohos/flutter_ohos';

export class PickedDocuments {
  files: string[] = [];
  folders: string[] = [];
}

export class DocumentPickerPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  getUniqueClassName(): string {
    return 'LocalSendDocumentPicker';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), 'org.localsend.localsend_app/harmony_documents');
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'pickFiles') {
      this.pickFiles().then((paths: string[]) => result.success(paths)).catch(() => {
        result.error('PICK_FILES', 'Unable to read the selected files', null);
      });
    } else if (call.method === 'pickFolder' || call.method === 'pickDestination') {
      this.pickFolder(call.method === 'pickDestination')
        .then((path: string | null) => result.success(path))
        .catch((error: BusinessError) => result.error('PICK_FOLDER', error.message, error.code));
    } else if (call.method === 'activateDestination' || call.method === 'forgetDestination') {
      const uri = call.args as string;
      const policies = this.destinationPolicy(uri);
      const promise = call.method === 'activateDestination'
        ? fileShare.activatePermission(policies)
        : fileShare.revokePermission(policies);
      promise.then(() => result.success(null))
        .catch((error: BusinessError) => result.error('DESTINATION_ACCESS', error.message, error.code));
    } else if (call.method === 'openFolder' || call.method === 'openFile') {
      this.openDocument(call.args as string, call.method === 'openFolder')
        .then(() => result.success(null))
        .catch((error: BusinessError) => result.error('OPEN_DOCUMENT', error.message, error.code));
    } else if (call.method === 'clearStaleSelections') {
      this.clearStaleSelections().then(() => result.success(null))
        .catch((error: BusinessError) => result.error('CLEAR_SELECTIONS', error.message, error.code));
    } else {
      result.notImplemented();
    }
  }

  private async openDocument(path: string, folder: boolean): Promise<void> {
    const uri = path.startsWith('/storage/Users/currentUser/')
      ? 'file://docs' + path.split('/').map((part: string) => encodeURIComponent(part)).join('/')
      : fileUri.getUriFromPath(path);
    if (folder) {
      await this.context.openLink('filemanager://openDirectory', { parameters: { fileUri: uri } });
      return;
    }
    const extensionIndex = path.lastIndexOf('.');
    const hasExtension = extensionIndex > path.lastIndexOf('/');
    const type = hasExtension
      ? uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(path.substring(extensionIndex))
      : uniformTypeDescriptor.UniformDataType.FILE;
    await this.context.startAbility({
      action: 'ohos.want.action.viewData',
      uri: uri,
      type: type,
      flags: wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION
    });
  }

  private async clearStaleSelections(): Promise<void> {
    const cacheDirectory = this.context.cacheDir;
    for (const name of await fileIo.listFile(cacheDirectory)) {
      if (/^localsend-selection-[a-zA-Z0-9]{6}$/.test(name)) {
        await fileIo.rmdir(cacheDirectory + '/' + name).catch(() => {});
      }
    }
  }

  private destinationPolicy(uri: string): fileShare.PolicyInfo[] {
    return [{ uri: uri, operationMode: fileShare.OperationMode.READ_MODE | fileShare.OperationMode.WRITE_MODE }];
  }

  private async pickFolder(persist: boolean): Promise<string | null> {
    const options = new picker.DocumentSelectOptions();
    options.selectMode = picker.DocumentSelectMode.FOLDER;
    options.maxSelectNumber = 1;
    const uris = await new picker.DocumentViewPicker(this.context).select(options);
    if (uris.length === 0) {
      return null;
    }
    const uri = uris[0];
    const path = new fileUri.FileUri(uri).path;
    if (!(await fileIo.stat(path)).isDirectory()) {
      throw new Error('The selected location is not a directory');
    }
    if (persist) {
      const policies = this.destinationPolicy(uri);
      await fileShare.persistPermission(policies);
      return uri;
    }
    return path;
  }

  private async pickFiles(): Promise<string[]> {
    const options = new picker.DocumentSelectOptions();
    options.maxSelectNumber = 500;
    const uris = await new picker.DocumentViewPicker(this.context).select(options);
    return (await this.prepareDocuments(uris, false)).files;
  }

  async prepareDocuments(uris: string[], allowFolders: boolean): Promise<PickedDocuments> {
    const staged: string[] = [];
    const picked = new PickedDocuments();
    try {
      for (const uri of uris) {
        if (!uri.startsWith('file://')) {
          throw new Error('Unsupported document URI');
        }
        const file = new fileUri.FileUri(uri);
        if (file.host === this.context.abilityInfo.bundleName) {
          throw new Error('An external selection cannot use LocalSend private data');
        }
        const path = file.path;
        const direct = file.host === 'docs' && path.startsWith('/storage/Users/currentUser/');
        const stat = direct ? await fileIo.lstat(path).catch(() => null) : null;
        if (stat?.isDirectory() && allowFolders) {
          await fileIo.listFile(path, { listNum: 1 });
          picked.folders.push(path);
          continue;
        }

        // Public documents may be accessed directly while the system grant
        // is active. Other providers expose the content through a URI only.
        const directFile = stat?.isFile()
          ? await fileIo.open(path, fileIo.OpenMode.READ_ONLY | fileIo.OpenMode.NOFOLLOW).catch(() => null)
          : null;
        if (directFile) {
          await fileIo.close(directFile);
          picked.files.push(path);
          continue;
        }

        const source = await fileIo.open(uri, fileIo.OpenMode.READ_ONLY | fileIo.OpenMode.NOFOLLOW);
        try {
          const name = source.name;
          const sourceStat = await fileIo.stat(source.fd);
          if (!sourceStat.isFile() || !name || name === '.' || name === '..' || name.includes('/') || name.includes('\\')) {
            throw new Error('Invalid document name');
          }
          const directory = await fileIo.mkdtemp(this.context.cacheDir + '/localsend-selection-XXXXXX');
          staged.push(directory);
          const cachePath = directory + '/' + name;
          await fileIo.copyFile(source.fd, cachePath);
          fileIo.utimes(cachePath, sourceStat.mtime * 1000);
          picked.files.push(cachePath);
        } finally {
          await fileIo.close(source);
        }
      }
      return picked;
    } catch (error) {
      for (const directory of staged) {
        await fileIo.rmdir(directory).catch(() => {});
      }
      throw new Error('Unable to read the selected documents');
    }
  }
}
