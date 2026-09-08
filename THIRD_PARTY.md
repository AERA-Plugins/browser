# Third-party components

The release payload contains WPE WebKit and supporting libraries, fonts,
certificate data, and Unicode data. These components are not relicensed under
the repository's Apache-2.0 license. They remain governed by their upstream
LGPL, BSD, MIT, font, and data licenses.

The runtime uses WPE WebKit 2.52.6. Version 1.2 also carries Mesa 26.2.2
(Zink and Turnip only), the Khronos Vulkan loader, and libdrm for the
surfaceless Adreno KGSL rendering path. Mesa's license text is included under
`/usr/share/licenses/mesa/` in the payload.

Distributors must preserve all license files and provide corresponding source
as required by the LGPL and other component licenses. A reproducible source
bundle and security-update notes must accompany production releases.
