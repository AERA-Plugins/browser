#!/bin/bash
set -euo pipefail
# Build against the already-built WPE 2.52.6 tree; no engine rebuild needed.
browser_sources=$(cd -- "$(dirname -- "$0")" && pwd)
webkit_build=${AERA_WEBKIT_BUILD:-/tmp/aera-webkit/build21}
webkit_source=${AERA_WEBKIT_SOURCE:-/tmp/wpewebkit-2.52.6}
browser_sysroot=${AERA_BROWSER_SYSROOT:-/tmp/aera-webkit-sysroot}
browser_output=${1:?Pass an output directory}
mkdir -p "$browser_output"
read -r -a glib_cflags <<< "$(/tmp/aera-webkit/pkg-config --cflags gio-unix-2.0 libsoup-3.0)"
read -r -a glib_libs <<< "$(/tmp/aera-webkit/pkg-config --libs gio-unix-2.0)"
target_flags=(--target=aarch64-alpine-linux-musl --sysroot="$browser_sysroot"
  --gcc-toolchain="$browser_sysroot/usr")
/tmp/aera-webkit/clang++ "${target_flags[@]}" -std=c++17 -Os -g0 -Wall -Wextra -Werror \
  -I"$webkit_build/DerivedSources/WebKit" -I"$webkit_build/DerivedSources/WPEPlatform" \
  -I"$webkit_source/Source/WebKit/UIProcess/API" \
  -I"$webkit_build/JavaScriptCoreGLib/DerivedSources" \
  -I"$webkit_build/JavaScriptCoreGLib/Headers" \
  -I"$webkit_source/Source/WebKit/WPEPlatform" "${glib_cflags[@]}" \
  -c "$browser_sources/worker.cpp" -o "$browser_output/worker.o"
/tmp/aera-webkit/clang++ "${target_flags[@]}" \
  --ld-path=/home/koaan/android/fox_14.1/prebuilts/clang/host/linux-x86/clang-r510928/bin/ld.lld \
  "$browser_output/worker.o" -L"$webkit_build/lib" -lWPEWebKit-2.0 "${glib_libs[@]}" \
  -Wl,-z,relro,-z,now -Wl,--gc-sections -o "$browser_output/aera-browser-worker"
/home/koaan/android/fox_14.1/prebuilts/clang/host/linux-x86/clang-r510928/bin/llvm-strip \
  --strip-unneeded "$browser_output/aera-browser-worker"
