<!--
SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>

SPDX-License-Identifier: CC0-1.0
-->

# Contributing tips

This file describes some non-obvious points of this project which needs to be known by contributors.

## Technology stack

Text Pieces is written in [Vala](https://wiki.gnome.org/Projects/Vala) using [GTK 4](https://gtk.org) and [libadwaita](https://gitlab.gnome.org/GNOME/libadwaita/) as GUI libraries. Text Pieces is designed to comply [GNOME HIG](https://developer.gnome.org/hig) guidelines. It also uses [gtksourceview](https://gitlab.gnome.org/GNOME/gtksourceview) for text editor widget and [json-glib](https://gitlab.gnome.org/GNOME/json-glib/) for JSON serialization and deserialization.

Text Pieces' built-in tools uses [Python](https://www.python.org/) and [Bash](https://www.gnu.org/software/bash/) as interpreters, [pyyaml](https://pyyaml.org/) for JSON to YAML and YAML to JSON conversion and [gettext](https://www.gnu.org/software/gettext/) for translations.

It also uses [shebang](https://wikipedia.org/en/Shebang_(Unix)) for script executing, so it can work only on UNIX-like OSes.

## Build system

Text Pieces uses [Meson](https://mesonbuild.com) as build system and [Flatpak](https://flatpak.org) as packaging system. Flatpak manifest is stored at `build-aux/flatpak/com.github.liferooter.textpieces.yaml`.

## Conventions

Text Pieces uses some conventions:
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages
- [Elementary Codestyle](https://docs.elementary.io/develop/writing-apps/code-style) for Vala code
- [PEP 8](https://peps.python.org/pep-0008/) for Python-based tools
- [REUSE](https://reuse.software/) licensing conventions
- [GNU GPL 3.0 or later](https://www.gnu.org/licenses/gpl-3.0.en.html) license for code, [CC0](https://creativecommons.org/share-your-work/public-domain/cc0) licencse for metadata and anything else
- [Semantic Versioning](https://semver.org/)
- [GNOME HIG](https://developer.gnome.org/hig) for user interface

## Post-commit checks

There are some things you should do after making changes in project code:

### Update translation templates

If you've changed any translatable strings in application, you should regenerate translation template:

```bash
meson _build
ninja -C _build textpieces-pot
ninja -C _build textpieces-update-po
```

If you've changed translatable strings in `data/tools.json`, please add your changes manually to `po/tools.pot`.

### Licensing checks

As Text Pieces is REUSE-compilant project, you have to copyright headers in any file you create or edit. The simpliest way to do it is:

```bash
pip install --user reuse
reuse addheader --copyright 'YOUR NAME <YOUR@EMAIL.ADDRESS>' --year CURRENT_YEAR LICENSE_NAME FILE_NAME
```

## Copyright policy

Text Pieces is open-source project and will stay open-source forever. To make this rule non-breakable, you should add your copyright to any file you change or create. This makes license changing impossible without permission from everyone who ever contributes to the project.

## Creating translation

Text Pieces uses `gettext` for localization. Translations can be suggested by PR. The only important point is `po/tools.pot`. It's manually-written translate template for tools metadata (`gettext` can't extract translatable strings from JSON files). Translators have to insert its translation right after `po/textpieces.pot` translation. Also translator should place their copyright note in translation file.
