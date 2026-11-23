# LocalSend

> **非官方鸿蒙 PC 移植版 / Unofficial HarmonyOS PC port**
>
> 基于 LocalSend v1.18.2，面向 ARM64 鸿蒙电脑（PC/2-in-1）。
>
> Based on LocalSend v1.18.2 for ARM64 HarmonyOS PC/2-in-1 devices.

## 鸿蒙 PC 移植贡献 / HarmonyOS PC port contributions

### 中文

- **平台适配。** 沿用 LocalSend 原版的 Flutter 界面和 Rust 传输核心，新增鸿蒙 PC 的 ARM64 构建、系统文件与文件夹选择、公共收件目录授权及重启恢复、拖放、剪贴板和系统托盘。
- **真机验证。** 在运行 OpenHarmony 6.1.1.135 的鸿蒙电脑上通过 USB 安装和调试。通过局域网 HTTPS 接收测试文件，再将目录发回 Mac 上的协议测试程序。回传的 50 个文件包含一个 128 MiB 文件及其编号副本，逐一核对了相对路径、字节数和 SHA-256。
- **人员与 AI 参与。** [@maopai](https://github.com/maopai) 发起移植、确定适配目标、开启 USB 调试，并在实体电脑上亲自验证了消息框的键盘输入。Codex 协助编写了大部分鸿蒙平台集成和构建脚本，参与故障排查、自动化验证和文档编写。

[构建说明与真机测试记录](app/ohos/README.md)

### English

- **Platform support.** The port keeps LocalSend’s Flutter UI and Rust transfer core and adds an ARM64 HarmonyOS PC build, native file and folder pickers, public receive-folder access across restarts, drag and drop, clipboard support, and system tray integration.
- **Hardware verification.** We installed and debugged the app over USB on a HarmonyOS PC running OpenHarmony 6.1.1.135. A local-network HTTPS round trip with a protocol test peer on a Mac verified the relative paths, byte counts, and SHA-256 hashes of all 50 files, including a 128 MiB file and its numbered copy.
- **Human and AI contributions.** [@maopai](https://github.com/maopai) initiated the port, set its goals, enabled USB debugging, and personally verified physical-keyboard input in the message dialog. Codex helped write much of the HarmonyOS integration and build tooling, troubleshoot issues, run automated checks, and prepare documentation.

[Build instructions and device test results](app/ohos/README.md)

[![CI status][ci-badge]][ci-workflow]
[![Translations][translate-badge]][translate-link]
[![Packaging status][packaging-badge]][packaging-link]

[ci-badge]: https://github.com/localsend/localsend/actions/workflows/ci.yml/badge.svg
[ci-workflow]: https://github.com/localsend/localsend/actions/workflows/ci.yml
[translate-badge]: https://hosted.weblate.org/widget/localsend/app/svg-badge.svg
[translate-link]: https://hosted.weblate.org/engage/localsend/
[packaging-badge]: https://repology.org/badge/tiny-repos/localsend.svg
[packaging-link]: https://repology.org/project/localsend/versions

[Homepage][homepage] • [Discord][discord] • [GitHub][github] • [Codeberg][codeberg]

[English (Default)](README.md) • [Беларуская](/support/readme/README_BE.md) • [Español](/support/readme/README_ES.md) • [فارسی](/support/readme/README_FA.md) • [Filipino](/support/readme/README_PH.md) • [Français](/support/readme/README_FR.md) • [Indonesia](/support/readme/README_ID.md) • [Italiano](/support/readme/README_IT.md) • [日本語](/support/readme/README_JA.md) • [ភាសាខ្មែរ](/support/readme/README_KM.md) • [한국어](/support/readme/README_KO.md) • [Polski](/support/readme/README_PL.md) • [Português Brasil](/support/readme/README_PT_BR.md) • [Русский](/support/readme/README_RU.md) • [ภาษาไทย](/support/readme/README_TH.md) • [Türkçe](/support/readme/README_TR.md) • [Українська](/support/readme/README_UK.md) • [Tiếng Việt](/support/readme/README_VI.md) • [中文](/support/readme/README_ZH.md)

[homepage]: https://localsend.org
[discord]: https://discord.gg/GSRWmQNP87
[github]: https://github.com/localsend/localsend
[codeberg]: https://codeberg.org/localsend/localsend

LocalSend is a free, open-source app that allows you to securely share files and messages with nearby devices over your local network without needing an internet connection.

- [About](#about)
- [Sponsors](#sponsors)
- [Screenshots](#screenshots)
- [Download](#download)
- [How It Works](#how-it-works)
- [Dependency Hierarchy](#dependency-hierarchy)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
  - [Translation](#translation)
  - [Bug Fixes and Improvements](#bug-fixes-and-improvements)
- [Troubleshooting](#troubleshooting)
- [Building](#building)
  - [Android](#android)
  - [iOS](#ios)
  - [macOS](#macos)
  - [Windows](#windows)
  - [Linux](#linux)

## About

LocalSend is a cross-platform app that enables secure communication between devices using a REST API and HTTPS encryption. Unlike other messaging apps that rely on external servers, LocalSend doesn't require an internet connection or third-party servers, making it a fast and reliable solution for local communication.

## Sponsors

Browser testing via

<a href="https://www.testmuai.com/?utm_medium=sponsor&utm_source=localsend" target="_blank">
    <img src="https://localsend.org/img/sponsors/tesmu.svg" style="vertical-align: middle;" width="250" height="45" />
</a>

## Screenshots

<img src="https://localsend.org/img/screenshot-iphone.webp" alt="iPhone screenshot" height="300"/> <img src="https://localsend.org/img/screenshot-pc.webp" alt="PC screenshot" height="300"/>

## Download

[![Packaging status](https://repology.org/badge/tiny-repos/localsend.svg)](https://repology.org/project/localsend/versions)

It is recommended to download the app either from an app store or from a package manager because the app does not have an auto-update.

| Windows                 | macOS                   | Linux              | Android        | iOS           | Fire OS    |
|-------------------------|-------------------------|--------------------|----------------|---------------|------------|
| [Winget][]              | [App Store][]           | [Flathub][]        | [Play Store][] | [App Store][] | [Amazon][] |
| [Scoop][]               | [Homebrew][]            | [Nixpkgs][]        | [F-Droid][]    |               |            |
| [Chocolatey][]          | [DMG Installer][latest] | [Snap][]           | [APK][latest]  |               |            |
| [EXE Installer][latest] |                         | [AUR][]            |                |               |            |
| [Portable ZIP][latest]  |                         | [TAR][latest]      |                |               |            |
|                         |                         | [DEB][latest]      |                |               |            |
|                         |                         | [AppImage][latest] |                |               |            |

Read more about [distribution channels][].

Windows binaries are signed. Read more about the [Code signing policy][].

> [!CAUTION]
> **Unofficial MSIX preview:** you can try builds from the latest commits at [localsend.ob-buff.dev](https://localsend.ob-buff.dev/). Stability is not guaranteed and all custom code tweaks are listed on that site.

[windows store]: https://www.microsoft.com/store/apps/9NCB4Z0TZ6RR
[app store]: https://apps.apple.com/us/app/localsend/id1661733229
[play store]: https://play.google.com/store/apps/details?id=org.localsend.localsend_app
[f-droid]: https://f-droid.org/packages/org.localsend.localsend_app
[amazon]: https://www.amazon.com/dp/B0BW6MP732
[winget]: https://github.com/microsoft/winget-pkgs/tree/master/manifests/l/LocalSend/LocalSend
[scoop]: https://scoop.sh/#/apps?s=0&d=1&o=true&q=localsend&id=fb88113be361ca32c0dcac423cb4afdeda0b0c66
[chocolatey]: https://community.chocolatey.org/packages/localsend
[homebrew]: https://formulae.brew.sh/cask/localsend
[flathub]: https://flathub.org/apps/details/org.localsend.localsend_app
[nixpkgs]: https://search.nixos.org/packages?show=localsend
[snap]: https://snapcraft.io/localsend
[aur]: https://aur.archlinux.org/packages/localsend-bin
[latest]: https://github.com/localsend/localsend/releases/latest
[distribution channels]: https://github.com/localsend/localsend/blob/main/CONTRIBUTING.md#distribution
[code signing policy]: https://github.com/localsend/localsend/blob/main/CODE_SIGNING.md

**Compatibility**

| Platform | Minimum Version | Note                                                                                                                        |
|----------|-----------------|-----------------------------------------------------------------------------------------------------------------------------|
| Android  | 5.0             | -                                                                                                                           |
| iOS      | 12.0            | -                                                                                                                           |
| macOS    | 11 Big Sur      | Use OpenCore Legacy Patcher 2.0.2 (See [#1005](https://github.com/localsend/localsend/issues/1005#issuecomment-2449899384)) |
| Windows  | 10              | The last version to support Windows 7 is v1.15.4. There might be backports of newer versions for Windows 7 in the future.   |
| Linux    | N.A.            | Deps: Gnome: `xdg-desktop-portal` and `xdg-desktop-portal-gtk`, KDE: `xdg-desktop-portal` and `xdg-desktop-portal-kde`      |

## Setup

In most cases, LocalSend should work out of the box. However, if you are having trouble sending or receiving files, you may need to configure your firewall to allow LocalSend to communicate over your local network.

| Traffic Type | Protocol | Port  | Action |
|--------------|----------|-------|--------|
| Incoming     | TCP, UDP | 53317 | Allow  |
| Outgoing     | TCP, UDP | Any   | Allow  |

Also make sure to disable AP isolation on your router. It should be usually disabled by default but some routers may have it enabled (especially guest networks).
See [troubleshooting](#troubleshooting) for more information.

**Portable Mode**

(Introduced in v1.13.0)

Create a file named `settings.json` located in the same directory as the executable.
This file can be empty.
The app will use this file to store settings instead of the default location.

**Start hidden**

(Updated in v1.15.0)

To start the app hidden (only in tray), use the `--hidden` flag (example: `localsend_app.exe --hidden`).

On v1.14.0 and earlier, the app starts hidden if `autostart` flag is set, and the hidden setting is enabled.

## How It Works

LocalSend uses a secure communication protocol that allows devices to communicate with each other using a REST API. All data is sent securely over HTTPS, and the TLS/SSL certificate is generated on the fly on each device, ensuring maximum security.

For more information on the LocalSend Protocol, see the [documentation](https://github.com/localsend/protocol).

## Dependency Hierarchy

![Dependency hierarchy](support/docs/dependency-hierarchy.svg)

## Getting Started

To compile LocalSend from the source code, follow these steps:

1. Install Flutter [directly](https://flutter.dev) or using [fvm](https://fvm.app) (see [version required](.fvmrc))
2. Install [Rust](https://www.rust-lang.org/tools/install)
3. Clone the `LocalSend` repository
4. Run `cd app` to enter the app directory
5. Run `flutter pub get` to download dependencies
6. Run `flutter run` to start the app

> [!NOTE]
> LocalSend currently requires an older Flutter version (specified in [.fvmrc](.fvmrc))
> and thus build issues may be caused by a mismatch between the required and the (system-wide) installed Flutter version.  
> To make development more consistent, LocalSend uses [fvm](https://fvm.app) to manage the project Flutter version.
> After installing `fvm`, run `fvm flutter` instead of `flutter`.

## Contributing

We welcome contributions from anyone interested in helping improve LocalSend. If you'd like to contribute, there are a few ways to get involved:

### Translation

You can help translate LocalSend into other languages. We use the [Weblate](https://hosted.weblate.org/projects/localsend/app) platform to manage translations.

Alternatively, you can also contribute by forking this repository and adding translations manually.

The translations are located in the [app/assets/i18n](https://github.com/localsend/localsend/tree/main/app/assets/i18n) directory. Edit the `_missing_translations_<locale>.json` or `strings_<locale>.i18n.json` file to add or update translations.

<a href="https://hosted.weblate.org/engage/localsend/">
<img src="https://hosted.weblate.org/widget/localsend/app/multi-auto.svg" alt="Translation status" />
</a>

**_Take note:_ Fields decorated with `@` are not meant to be translated; they are not used in the app in any way, being merely informative text about the file or to give context to the translator.**

### Bug Fixes and Improvements

- **Bug Fixes:** If you find a bug, please create a pull request with a clear description of the issue and how to fix it.
- **Improvements:** Have an idea for how to improve LocalSend? Please create an issue first to discuss why the improvement is needed.

For more information, see the [contributing guide](https://github.com/localsend/localsend/blob/main/CONTRIBUTING.md).

## Troubleshooting

| Issue              | Platform (Sending) | Platform (Receiving) | Solution                                                                                                                                |
|--------------------|--------------------|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| Device not visible | Any                | Any                  | Make sure to disable AP-Isolation on your router. If it is enabled, connections between devices are forbidden.                          |
| Device not visible | Any                | Windows              | Make sure to configure your network as a "private" network. Windows might be more restrictive when the network is configured as public. |
| Device not visible | macOS, iOS         | Any                  | You can try to toggle the "Local Network" permission under "Privacy" in the OS settings.                                                |
| Speed too slow     | Any                | Any                  | Use 5 Ghz; Disable encryption on both devices                                                                                           |
| Speed too slow     | Any                | Android              | Known issue. https://github.com/flutter-cavalry/saf_stream/issues/4                                                                     |

## Building

These commands are intended for maintainers only. Make sure to run them from the `app` directory.

### Android

Traditional APK

```bash
flutter build apk
```

AppBundle for Google Play

```bash
flutter build appbundle
```

### iOS

```bash
flutter build ipa
```

### macOS

```bash
flutter build macos
```

### Windows

**Traditional**

```bash
flutter build windows
```

**Local MSIX App**

```bash
flutter pub run msix:create
```

**Store ready**

```bash
flutter pub run msix:create --store
```

### Linux

**Traditional**

```bash
flutter build linux
```

**AppImage**

```bash
appimage-builder --recipe AppImageBuilder.yml
```

**Snap**

Instructions in [localsend/snap/README.md](https://github.com/localsend/snap/blob/main/README.md)

## Contributors

<a href="https://github.com/localsend/localsend/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=localsend/localsend"  alt="Localsend Contributors"/>
</a>
