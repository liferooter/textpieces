textpieces_sources += [
  'AboutDialog.vala',
  'Application.vala',
  'Argument.vala',
  'MainWindow.vala',
  'Preferences.vala',
  'Search.vala',
  'ShortcutsWindow.vala',
  'Tool.vala',
  'ToolEntry.vala',
  'ToolPopover.vala',
]

textpieces_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gtksourceview-4', version: '>= 4.8'),
  dependency('libhandy-1', version: '>= 1.0.3'),
  dependency('json-glib-1.0', version: '>= 1.6.2'),
  valac.find_library('config', dirs: vapi_dir),
]

c_args = [
  '-DVERSION="' + meson.project_version() + '"',
]

vala_args = [
  '--enable-experimental-non-null',
  '--target-glib=2.50',
  '--vapidir', vapi_dir,
]

executable('textpieces', textpieces_sources,
  vala_args: vala_args, c_args: c_args,
  dependencies: textpieces_deps,
  install: true,
)
