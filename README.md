<h1 align="center">
<img
    src="data/icons/com.github.liferooter.textpieces.svg" alt="Text Pieces"
    width="128"
    height="128"/><br/>
Text Pieces
</h1>

<p align="center"><strong>
Swiss knife of text processing
</strong></p>

<br/>

<p align="center">
<a href="https://stopthemingmy.app">
    <img width="200" src="https://stopthemingmy.app/badge.svg"/>
</a>
</p>

<p align="center">
<a href="https://flathub.org/apps/details/com.github.liferooter.textpieces">
    <img width="200" src="https://flathub.org/assets/badges/flathub-badge-en.png" alt="Download on Flathub">
</a>
</p>


Small tool for quick text transformations such as checksums, encoding, decoding and so on. Written in Vala for GNOME desktop in hope to be useful.

# Features
- Base64 encoding and decoding
- SHA1, SHA2 and MD5 checksums
- Prettify and minify JSON
- Covert JSON to YAML and vice versa
- Count lines, symmbols and words
- Escape and unescape string, URL and HTML
- Remove leading and trailing whitespaces
- Sort and reverse sort lines
- Reverse lines and whole text
- You can write your own scripts and create custom tools

# Screenshots
<img alt="Screenshot" src="screenshots/screenshot1.png"/>
<img alt="Screenshot" src="screenshots/screenshot2.png"/>
<img alt="Screenshot" src="screenshots/screenshot3.png"/>

# Installation

## From Flathub
> **Recommended**

You can install my app from Flathub <a href="https://flathub.org/apps/details/com.github.liferooter.textpieces">here</a>

## Build from source
### Via GNOME Builder
Text Pieces can be built with GNOME Builder >= 3.38. Just clone this repo and click run button.
### Via Flatpak
Text Pieces has Flatpak manifest, so it can be <a href="https://docs.flatpak.org/en/latest/building-introduction.html">built with Flatpak</a>.
### Via Meson
Text Pieces can be built directly via Meson:
```bash
git clone https://github.com/liferooter/textpieces
cd textpieces
meson _build
cd _build
meson compile
```
Next, it can be installed by `meson install`.

**Attention! You should NEVER install anything directly with `meson install` or `make install` because it creates unmanaged files and can break system**

# Dependencies
If you use GNOME Builder or Flatpak, dependencies will be installed automatically. If you use pure Meson, dependencies will be:
- vala >= 0.52
- gtk >= 4.2
- gtksourceview >= 5.0
- gio >= 2.50
- json-glib >= 1.6
- libadwaita >= 1.0
- python >= 3.8
- pyyaml >= 5.4

# Contributions
Contributions are welcome.
