# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

textpieces_sources += [
  'Application.vala',
  'CustomToolPage.vala',
  'Editor.vala',
  'NewToolPage.vala',
  'Preferences.vala',
  'Recoloring.vala',
  'Search.vala',
  'Tool.vala',
  'ToolSettings.vala',
  'ToolsController.vala',
  'Utils.vala',
  'Window.vala',
]

textpieces_sources += custom_target('blueprint-hack',
    input: blueprints,
    output: 'blueprint.vala',
    command: [find_program('touch'), '@OUTPUT@']
)

executable('textpieces', textpieces_sources,
  c_args: [
    '-DVERSION="' + meson.project_version() + '"',
    '-DPKGDATADIR="' + pkgdata_dir + '"',
    '-DSCRIPTDIR="' +  pkgdata_dir / 'scripts' + '"',
    '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
    '-DGNOMELOCALEDIR="' + get_option('prefix') / get_option('localedir') + '"',
  ],
  vala_args: [
    '--gresourcesdir=' + generated_resources_dir
  ],
  dependencies: textpieces_deps,
  install: true,
)
