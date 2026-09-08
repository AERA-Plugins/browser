# AERA Browser Plugin

The official browser runtime plugin for AERA Recovery Project.

The recovery image contains the small native LVGL browser host and its hardened
unprivileged launcher. This repository distributes the larger WPE WebKit runtime
as a signed, optional plugin. Plugin Manager can install it persistently under
`/sdcard/AERA/plugins/browser` or load it into `/tmp/aera/plugins/browser` for
the current recovery session only.

Version 1.2 retains the sharp 1080×1920 backing surface and 360×640 logical
mobile viewport, and adds hardware page compositing through Mesa 26.2.2,
Zink, Turnip, and the OP13 Adreno 830 KGSL device. Video decoding remains on
the CPU; page layers, scrolling, transforms, and final browser composition use
the GPU. The isolated browser receives neither the recovery framebuffer nor
Android's vendor EGL stack.

Video audio uses a dedicated GStreamer sink. The sink can only send fixed
48 kHz stereo PCM to AERA's root-owned local audio bridge; the isolated browser
never receives direct ALSA, Binder, or partition access.

## Trust model

- `plugin.json` is signed with the AERA Ed25519 release key.
- The signed manifest pins the exact payload size and SHA-256.
- AERA verifies the signature before download publication and hashes the full
  payload again before extracting it into RAM.
- Web content runs in AERA's fixed browser jail; the plugin does not receive
  recovery partition or decrypted-storage access.
- The jail exposes only `/dev/kgsl-3d0` and `/dev/dma_heap/system` for rendering;
  display, input, camera, Binder, and storage devices remain hidden.

## Building

`source/` contains AERA's browser worker, runtime packer, build notes, and the
small WPE/Mesa patches required for the KGSL surfaceless path. WPE WebKit and
the other bundled libraries remain under their respective upstream licenses.
Rebuild the staged ARM64 runtime, then run:

```sh
python3 source/pack.py STAGED_RUNTIME OUTPUT_DIRECTORY
```

Update every generated size/hash field in `plugin.json`, sign the exact file,
and attach `runtime.xz` to the matching GitHub release.

## Signing

```sh
openssl pkeyutl -sign -rawin -inkey "$AERA_PLUGIN_PRIVATE_KEY" \
  -in plugin.json -out plugin.json.sig.bin
xxd -p -c 256 plugin.json.sig.bin > plugin.json.sig
```

Never commit the private signing key.
