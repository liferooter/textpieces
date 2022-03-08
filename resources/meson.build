# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

blueprints = custom_target('blueprints',
  input: files(
    'ui/CustomToolPage.blp',
    'ui/NewToolPage.blp',
    'ui/Preferences.blp',
    'ui/ShortcutsWindow.blp',
    'ui/ToolSettings.blp',
    'ui/Window.blp',
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

textpieces_sources += gnome.compile_resources('textpieces-resources',
  'textpieces.gresource.xml',
  source_dir: 'resources',
  c_name: 'textpieces',
  dependencies: blueprints,
)
