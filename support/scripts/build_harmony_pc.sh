#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."
project="$PWD"
studio="${DEVECO_HOME:-/Applications/DevEco-Studio.app}/Contents"
flutter_sdk="${FLUTTER_OHOS_ROOT:-$(dirname "$project")/Flutter-OHOS-3.41.9}"

export JAVA_HOME="$studio/jbr/Contents/Home"
export NODE_HOME="$studio/tools/node"
export HVIGOR_HOME="$studio/tools/hvigor"
export DEVECO_SDK_HOME="$studio/sdk"
export DEVECO_STUDIO_HOME="$studio"
export OHOS_HOME="$DEVECO_SDK_HOME"
native="$DEVECO_SDK_HOME/default/openharmony/native"
export PATH="$JAVA_HOME/bin:$NODE_HOME/bin:$HVIGOR_HOME/bin:$studio/tools/ohpm/bin:$DEVECO_SDK_HOME/default/openharmony/toolchains:$PATH"

# The development bootstrap can provide a project-local Rust toolchain.
local_rust="$project/.git/rustup-ohos/toolchains/1.97.1-aarch64-apple-darwin/bin"
if [[ -x "$local_rust/cargo" ]]; then
  export PATH="$local_rust:$PATH"
  export CARGO_HOME="$project/.git/cargo-ohos"
fi

export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_OHOS_LINKER="$native/llvm/bin/aarch64-unknown-linux-ohos-clang"
if [[ ! -x "$CARGO_TARGET_AARCH64_UNKNOWN_LINUX_OHOS_LINKER" ]]; then
  printf '%s\n' 'HarmonyOS SDK linker not found. Set DEVECO_HOME to the DevEco Studio .app directory.' >&2
  exit 1
fi
if [[ ! -x "$flutter_sdk/bin/flutter" ]]; then
  printf '%s\n' 'Flutter for OHOS not found. Set FLUTTER_OHOS_ROOT to the CPF-Flutter checkout.' >&2
  exit 1
fi
export CC_aarch64_unknown_linux_ohos="$CARGO_TARGET_AARCH64_UNKNOWN_LINUX_OHOS_LINKER"
export AR_aarch64_unknown_linux_ohos="$native/llvm/bin/llvm-ar"

cargo build --release --locked -p rust_lib_localsend_app --target aarch64-unknown-linux-ohos
hap_libs="app/ohos/entry/libs/arm64-v8a"
mkdir -p "$hap_libs"
"$native/llvm/bin/llvm-strip" --strip-unneeded -o "$hap_libs/librust_lib_localsend_app.so" \
  "${CARGO_TARGET_DIR:-target}/aarch64-unknown-linux-ohos/release/librust_lib_localsend_app.so"

profile=app/ohos/build-profile.json5
if [[ ! -e "$profile" ]]; then
  cp "$profile.template" "$profile"
fi

cd app
exec "$flutter_sdk/bin/flutter" build hap --target-platform ohos-arm64 "$@"
