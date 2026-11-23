import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { statusBarManager } from '@kit.DeskTopExtensionKit';
import { image } from '@kit.ImageKit';

export class StatusTray {
  minimizeOnClose: boolean = false;
  private registered: boolean = false;

  private context: common.UIAbilityContext;
  private appWindow: window.Window;

  constructor(context: common.UIAbilityContext, appWindow: window.Window) {
    this.context = context;
    this.appWindow = appWindow;
  }

  private onOpen = (): void => {
    this.show().catch(() => {});
  };

  private onMenuClick = (event: emitter.EventData): void => {
    const code = event.data?.['menuCode'] as string | undefined;
    if (code === 'close') {
      this.context.terminateSelf().catch(() => {});
    }
  };

  private onWindowClose = async (): Promise<boolean> => {
    if (!this.minimizeOnClose) {
      return false;
    }
    await this.appWindow.minimize();
    return true;
  };

  private async icon(name: string): Promise<image.PixelMap> {
    const bytes = await this.context.resourceManager.getMediaByName(name);
    const source = image.createImageSource(bytes.buffer as ArrayBuffer);
    try {
      return await source.createPixelMap();
    } finally {
      await source.release();
    }
  }

  async install(openLabel: string, closeLabel: string): Promise<void> {
    const menu: statusBarManager.StatusBarGroupMenu[] = [[
      { title: openLabel, menuAction: { abilityName: 'EntryAbility' } },
      { title: closeLabel, menuAction: { abilityName: 'EntryAbility', notifyOnly: true, menuCode: 'close' } }
    ]];
    if (this.registered) {
      statusBarManager.updateStatusBarMenu(this.context, menu);
      return;
    }

    const white = await this.icon('tray_white');
    const black = await this.icon('tray_black');
    try {
      await new Promise<void>((resolve, reject) => {
        statusBarManager.addToStatusBar(this.context, {
          icons: { white: white, black: black },
          quickOperation: { title: 'LocalSend', height: 48, abilityName: '' },
          statusBarGroupMenu: menu
        }, (error) => {
          if (error) {
            reject(error);
          } else {
            resolve();
          }
        });
      });
      this.registered = true;
      statusBarManager.on('statusBarIconClick', this.onOpen);
      statusBarManager.on('rightMenuClick', this.onMenuClick);
      this.appWindow.on('windowWillClose', this.onWindowClose);
    } finally {
      await white.release();
      await black.release();
    }
  }

  async show(): Promise<void> {
    if (!this.appWindow.isFocused()) {
      await this.context.startAbility({
        bundleName: this.context.abilityInfo.bundleName,
        moduleName: this.context.abilityInfo.moduleName,
        abilityName: this.context.abilityInfo.name
      });
    }
  }

  dispose(): void {
    if (this.registered) {
      this.appWindow.off('windowWillClose', this.onWindowClose);
      statusBarManager.off('statusBarIconClick', this.onOpen);
      statusBarManager.off('rightMenuClick', this.onMenuClick);
      statusBarManager.removeFromStatusBar(this.context);
      this.registered = false;
    }
  }
}
