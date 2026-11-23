# LocalSend for HarmonyOS PC

This is an unofficial port of [LocalSend v1.18.2](https://github.com/localsend/localsend/releases/tag/v1.18.2) (commit `af0416b`). It targets ARM64 HarmonyOS PC/2-in-1 devices and uses the LocalSend Flutter UI, translations, and Rust protocol implementation. The application bundle ID is `org.localsend.harmonypc`. The [upstream Apache 2.0 license](../../LICENSE) and vendored dependency licenses are included in the source tree.

## Build on macOS

The tested setup used an Apple Silicon Mac, [DevEco Studio](https://developer.huawei.com/consumer/en/doc/HarmonyOS-Guides/ide-software-install/) 26.0.0.865 with the bundled API 26 SDK, CPF-Flutter `3.41.9+ohos-1.0.4` (Dart 3.11.5), and Rust `1.97.1`. Use the HarmonyOS SDK bundled in DevEco Studio for this build. The test device ran OpenHarmony 6.1.1.135 (API 24).

From the root of a checkout of this fork's `harmony-pc` branch:

```sh
git clone --branch '3.41.9+ohos-1.0.4' --depth 1 \
  https://atomgit.com/CPF-Flutter/flutter_flutter.git ../Flutter-OHOS-3.41.9

rustup toolchain install 1.97.1 --component clippy
rustup target add --toolchain 1.97.1 aarch64-unknown-linux-ohos

export FLUTTER_OHOS_ROOT="$(cd ../Flutter-OHOS-3.41.9 && pwd)"
export DEVECO_HOME="/Applications/DevEco-Studio.app"

bash support/scripts/build_harmony_pc.sh --debug --no-codesign
```

Install [rustup](https://rustup.rs/) first if it is unavailable. Set `FLUTTER_OHOS_ROOT` and `DEVECO_HOME` to match your installation. The script uses DevEco's bundled JDK, Node, Hvigor, ohpm, and native linker. It builds the Rust library for `aarch64-unknown-linux-ohos`, stages it in the entry module, then builds the ARM64 HAP. A first run may download Flutter and package dependencies. The unsigned output is `app/build/ohos/hap/entry-default-unsigned.hap`.

### Local device installation

The first build copies `app/ohos/build-profile.json5.template` to the locally ignored `build-profile.json5` if it does not exist. The template contains no signing material. It can be used for an unsigned build. For a device build, open `app/ohos` in DevEco Studio, enable USB debugging on your HarmonyOS PC, and configure debug signing for the device in **Project Structure → Signing Configs**. Then build with the default signing behavior and install the signed output:

```sh
bash support/scripts/build_harmony_pc.sh --debug

HDC="$DEVECO_HOME/Contents/sdk/default/openharmony/toolchains/hdc"
"$HDC" list targets
"$HDC" -t '<USB target from the list>' install -r app/build/ohos/hap/entry-default-signed.hap
"$HDC" -t '<USB target from the list>' shell aa start -a EntryAbility -b org.localsend.harmonypc
```

The target ID used by HDC is specific to the connected device. The debug profile must authorize the device on which you install the HAP. Store your signing keys, certificates, and profiles outside the checkout. The project-level local signing configuration, development metadata, and generated packages are ignored by Git. The tracked module-level `entry/build-profile.json5` is build configuration shared by developers.

### Platform changes

- The HarmonyOS entry module implements the system file picker and folder permissions, file-manager integration, drag and drop, clipboard access, connectivity events, and system tray. Public receive destinations are authorized through the picker. LocalSend restores the saved authorization at startup and streams files directly from accessible paths. URI-only outgoing files use app-private staging.
- The Flutter Rust bridge opens the OHOS shared library explicitly in each Dart isolate. The upstream `packages/core` protocol source is unchanged.
- [`webrtc-util` 0.12.0](../../third_party/webrtc-util/) uses `nix` 0.31.4 on OHOS for network interface discovery. The original dependency is used on other targets. [`flex_color_picker` 3.8.0](../../third_party/flex_color_picker/) handles the extra target platform in the OHOS Flutter SDK. Both include their original licenses.

## Physical-device verification

Tested on an ARM64 HM740-091 HarmonyOS PC running OpenHarmony 6.1.1.135. The signed debug HAP was installed and Flutter was attached over USB. File transfers ran over local-network HTTPS. For repeatable checks of file size, relative path and SHA-256, we used a LocalSend protocol test peer on the Mac.

| Check | Observed result |
| --- | --- |
| Launch and discovery | The original Flutter Receive, Send and Settings pages rendered. The Send page discovered the official macOS LocalSend client. |
| Public receive folder and restart | A folder chosen in Settings received 25 files, including a 128 MiB file, a zero-byte file, and nested Unicode filenames. After force-stopping and restarting the HarmonyOS app, the same folder received the batch again. The second set received numbered filenames. |
| Folder send and integrity | The folder picker selected the entire received tree. The Mac test peer independently checked relative paths, byte counts and SHA-256 for all 50 files (270,696,448 bytes). |
| Native file integration | The progress page opened the exact public receive directory in the HarmonyOS file manager. File picker selection and cancel were exercised. |
| Drag and drop | A 1,100,000-byte file and a folder containing 12 files were dragged from the file manager to the app. Both transfers back to the Mac matched the source hashes. |
| Clipboard | Text and a file were added with the system Paste button. The transferred file matched the expected SHA-256. The project owner also verified physical-keyboard entry in the Flutter message dialog. |
| Tray | Closing with minimize-to-tray enabled kept the HTTPS server running in the same process. The tray icon restored the window, and the Exit LocalSend menu item stopped the process. |

To reproduce the file checks:

1. Connect both devices to the same local network and start LocalSend on each. Select a dedicated public folder in **Settings → Receive → Save to folder** on the HarmonyOS PC.
2. Send a test tree with nested directories, repeated basenames in separate directories, and at least one large file. Restart the HarmonyOS app and repeat the same transfer into the selected folder.
3. Use **Send → Folder** to send the received tree back. Compare the relative paths, file lengths, and SHA-256 digests on the Mac, including the numbered copies.
4. For desktop integration, drag a file and a directory from the file manager into LocalSend, copy a test file and add it using **Clipboard**, and verify that closing to the tray leaves the server reachable before restoring the window.

The latest bulk and drag transfers were checked against the Mac test peer. Full two-way interoperability with the official app still needs a separate pass on this build. Image clipboard data, browser transfers, WebRTC, share targets, startup integration, long-running background reception and release-signed distribution also remain to be verified. The PC test results do not cover HarmonyOS phones or tablets.
