import { connection } from '@kit.NetworkKit';
import { Any, EventChannel, EventSink, FlutterPlugin, FlutterPluginBinding, StreamHandler } from '@ohos/flutter_ohos';

const eventName = 'dev.fluttercommunity.plus/connectivity_status';

export class ConnectivityPlugin implements FlutterPlugin, StreamHandler {
  private monitor: connection.NetConnection | null = null;

  getUniqueClassName(): string {
    return 'LocalSendConnectivity';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    new EventChannel(binding.getBinaryMessenger(), eventName).setStreamHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.stopMonitoring();
    binding.getBinaryMessenger().setMessageHandler(eventName, null);
  }

  onListen(args: Any, events: EventSink): void {
    this.stopMonitoring();
    const monitor = connection.createNetConnection();
    this.monitor = monitor;
    const notify = (): void => {
      if (this.monitor !== monitor) {
        return;
      }
      events.success(this.defaultNetworkTypes());
    };
    monitor.on('netAvailable', notify);
    monitor.on('netLost', notify);
    monitor.on('netCapabilitiesChange', notify);
    monitor.on('netConnectionPropertiesChange', notify);
    monitor.register((error) => {
      if (this.monitor === monitor && error) {
        this.monitor = null;
      } else {
        notify();
      }
    });
  }

  onCancel(args: Any): void {
    this.stopMonitoring();
  }

  private stopMonitoring(): void {
    const monitor = this.monitor;
    this.monitor = null;
    monitor?.unregister(() => {});
  }

  private defaultNetworkTypes(): string[] {
    try {
      const net = connection.getDefaultNetSync();
      const names = ['mobile', 'wifi', 'bluetooth', 'ethernet', 'vpn'];
      const types = connection.getNetCapabilitiesSync(net).bearerTypes.map(type => names[type] ?? 'other');
      return types.length > 0 ? types : ['none'];
    } catch (error) {
      return ['none'];
    }
  }
}
