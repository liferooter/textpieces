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
  'Utils.vala'
]

c_args = [
  '-DVERSION="' + meson.project_version() + '"',
  '-DDATADIR="' + join_paths(get_option('prefix'), get_option('datadir')) + '"',
  '-DSCRIPTSDIR="' +  join_paths(get_option('prefix'), get_option('datadir'), 'scripts') + '"',
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
