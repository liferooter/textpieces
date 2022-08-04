# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

subdir('ui')

generated_resources_dir = meson.current_build_dir()

textpieces_sources += gnome.compile_resources('textpieces-resources',
  'textpieces.gresource.xml',
  source_dir: ['resources', generated_resources_dir],
  c_name: 'textpieces',
  dependencies: blueprints
)
