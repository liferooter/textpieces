# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

blueprints = custom_target('blueprints',
  input: files(
    'ui/CustomToolPage.blp',
    'ui/Editor.blp',
    'ui/NewToolPage.blp',
    'ui/Preferences.blp',
    'ui/SearchBar.blp',
    'ui/SearchEntry.blp',
    'ui/ShortcutsWindow.blp',
    'ui/ToolSettings.blp',
    'ui/Window.blp',
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

blueprint_vala = 'blueprint.vala'

blueprint_hack = custom_target('blueprint-hack',
  input: blueprints,
  output: blueprint_vala,
  command: [find_program('touch'), '@OUTPUT@']
)

textpieces_sources += gnome.compile_resources('textpieces-resources',
  'textpieces.gresource.xml',
  source_dir: 'resources',
  c_name: 'textpieces',
  dependencies: blueprints
)
