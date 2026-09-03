# Language icon assets

Except for `flag_enUS.tga`, the `flag_*.tga` files in this directory are local
TGA adaptations of the country-flag emoji artwork from OpenMoji 17.0.0.

- Project: OpenMoji
- Release: 17.0.0
- Source repository: https://github.com/hfg-gmuend/openmoji
- License: Creative Commons Attribution-ShareAlike 4.0 International
- License text: https://creativecommons.org/licenses/by-sa/4.0/
- OpenMoji licensing guidance: https://openmoji.org/faq

Source artwork and locale mapping:

- `flag_deDE.tga`: Germany, `1F1E9-1F1EA`
- `flag_frFR.tga`: France, `1F1EB-1F1F7`
- `flag_esES.tga`: Spain, `1F1EA-1F1F8`
- `flag_esMX.tga`: Mexico, `1F1F2-1F1FD`
- `flag_ptBR.tga`: Brazil, `1F1E7-1F1F7`
- `flag_itIT.tga`: Italy, `1F1EE-1F1F9`
- `flag_ruRU.tga`: Russia, `1F1F7-1F1FA`
- `flag_zhCN.tga`: China, `1F1E8-1F1F3`
- `flag_zhTW.tga`: Taiwan, `1F1F9-1F1FC`
- `flag_koKR.tga`: South Korea, `1F1F0-1F1F7`
- `flag_jaJP.tga`: Japan, `1F1EF-1F1F5`

Adaptation: the OpenMoji 618x618 PNG exports were alpha-cropped, proportionally
resampled with premultiplied-alpha Lanczos filtering, centered on transparent
128x128 canvases, and saved as uncompressed 32-bit TGA files for local WoW use.
No network resource is loaded by the addon at runtime.
