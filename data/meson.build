# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

desktop_file = i18n.merge_file(
  input: 'com.github.liferooter.textpieces.desktop.in',
  output: 'com.github.liferooter.textpieces.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

appstream_file = i18n.merge_file(
  input: 'com.github.liferooter.textpieces.appdata.xml.in',
  output: 'com.github.liferooter.textpieces.appdata.xml',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'appdata')
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util,
    args: ['validate', appstream_file]
  )
endif

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file', compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()]
  )
endif

install_data('com.github.liferooter.textpieces.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)


# Icons
install_data(
  join_paths('icons', 'com.github.liferooter.textpieces.svg'),
  install_dir: join_paths (get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps')
)
install_data(
  join_paths('icons', 'com.github.liferooter.textpieces-symbolic.svg'),
  install_dir: join_paths (get_option('datadir'), 'icons', 'hicolor', 'symbolic', 'apps')
)

# Tools' JSON
install_data (
  'tools.json',
  install_dir: pkgdata_dir
)
