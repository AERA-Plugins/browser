# AERA Browser Plugin

The official browser runtime plugin for AERA Recovery Project.

The recovery image contains the small native LVGL browser host and its hardened
unprivileged launcher. This repository distributes the larger WPE WebKit runtime
as a signed, optional plugin. Plugin Manager can install it persistently under
`/sdcard/AERA/plugins/browser` or load it into `/tmp/aera/plugins/browser` for
the current recovery session only.

## Trust model

- `plugin.json` is signed with the AERA Ed25519 release key.
- The signed manifest pins the exact payload size and SHA-256.
- AERA verifies the signature before download publication and hashes the full
  payload again before extracting it into RAM.
- Web content runs in AERA's fixed browser jail; the plugin does not receive
  recovery partition or decrypted-storage access.

## Building

`source/` contains AERA's browser worker, runtime packer, and build notes. WPE
WebKit and the other bundled libraries remain under their respective upstream
licenses. Rebuild the staged ARM64 runtime, then run:

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
