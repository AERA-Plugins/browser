# AERA Browser Plugin

The official browser runtime plugin for AERA Recovery Project.

The recovery image contains the small native LVGL browser host and its hardened
unprivileged launcher. This repository distributes the larger WPE WebKit runtime
as a signed, optional plugin. Plugin Manager can install it persistently under
`/sdcard/AERA/plugins/browser` or load it into `/tmp/aera/plugins/browser` for
the current recovery session only.

Version 1.5 uses a sharp 1080×2100 backing surface and 360×700 logical mobile
viewport so pages extend behind AERA's floating dock. It uses a 120 Hz WPE
frame scheduler and a double-buffered bridge that avoids the recovery-side
full-frame copy. Hardware page compositing uses Mesa 26.2.2,
Zink, Turnip, and the OP13 Adreno 830 KGSL device. Video decoding remains on
the CPU; page layers, scrolling, transforms, and final browser composition use
the GPU. The isolated browser receives neither the recovery framebuffer nor
Android's vendor EGL stack.

Pages without mobile viewport metadata are relaid out at phone width, and the
native two-touch bridge supports 50–300% pinch zoom without exposing recovery's
input devices. Downloads are managed by AERA and can write only to
`/sdcard/AERA/Downloads`; their progress is visible in the browser, status bar,
and Quick Settings.

Cookies and other WebKit site data persist in AERA's private recovery storage
at `/data/recovery/AERA/browser/profile`. The browser sees only that directory
as `/profile`; it is not exposed through shared storage. Browser Settings can
change the homepage, default zoom, and cookie policy, or clear cookies and site
data. The homepage and zoom preferences are stored with the other AERA settings
in `/sdcard/AERA/preferences.conf`.

Video audio uses a dedicated GStreamer sink. The sink can only send fixed
48 kHz stereo PCM to AERA's root-owned local audio bridge; the isolated browser
never receives direct ALSA, Binder, or partition access.

## Trust model

- `plugin.json` is signed with the AERA Ed25519 release key.
- The signed manifest pins the exact payload size and SHA-256.
- AERA verifies the signature before download publication and hashes the full
  payload again before extracting it into RAM.
- Web content runs in AERA's fixed browser jail; the plugin does not receive
  recovery partition or general decrypted-storage access.
- The jail exposes `/dev/kgsl-3d0` and `/dev/dma_heap/system` for rendering and
  two narrowly scoped writable binds for `/sdcard/AERA/Downloads` and its
  private `/profile`; display, input, camera, Binder, partitions, and all other
  storage remain hidden.

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
