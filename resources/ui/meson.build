# SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

blueprint_files = [
  'Editor.blp',
  'NewToolPage.blp',
  'CustomToolPage.blp',
  'Preferences.blp',
  'ShortcutsWindow.blp',
  'ToolSettings.blp',
  'Window.blp'
]

blueprint_ui = []
foreach b : blueprint_files
    blueprint_ui += b.replace('.blp', '.ui')
endforeach

blueprints = custom_target('blueprints',
  input: blueprint_files,
  output: blueprint_ui,
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTDIR@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)
