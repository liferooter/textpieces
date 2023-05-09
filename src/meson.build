# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

textpieces_sources += [
  'Application.vala',

  'tools/Tool.vala',
  'tools/ToolsController.vala',

  'widgets/Window.vala',
  'widgets/Editor.vala',
  'widgets/Search.vala',
  'widgets/SearchBar.vala',
  'widgets/SearchEntry.vala',

  'widgets/preferences/Preferences.vala',
  'widgets/preferences/ToolSettings.vala',

  'widgets/preferences/pages/CustomToolPage.vala',
  'widgets/preferences/pages/NewToolPage.vala',

  'utils/Utils.vala',
  'utils/Recoloring.vala',

]

executable('textpieces', [blueprint_hack, textpieces_sources],
  c_args: [
    '-DVERSION="' + meson.project_version() + '"',
    '-DPKGDATADIR="' + pkgdata_dir + '"',
    '-DSCRIPTDIR="' +  pkgdata_dir / 'scripts' + '"',
    '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
    '-DGNOMELOCALEDIR="' + get_option('prefix') / get_option('localedir') + '"',
  ],
  vala_args: [
    '--gresourcesdir=' + blueprints.full_path(),
  ],
  dependencies: textpieces_deps,
  install: true,
)
