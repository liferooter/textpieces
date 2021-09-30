textpieces_sources += [
  'Application.vala',
  'Window.vala',
  'Preferences.vala',
  'Tool.vala',
  'ToolsController.vala',
  'CustomToolRow.vala',
  'NewToolDialog.vala',
  'Utils.vala',
  'ThemeSwitcher.vala'
]

c_args = [
  '-DVERSION="' + meson.project_version() + '"',
  '-DPKGDATADIR="' + pkgdata_dir + '"',
  '-DSCRIPTDIR="' +  pkgdata_dir / 'scripts' + '"',
  '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
]

vala_args = [
  '--target-glib=2.50',
  '--vapidir', vapi_dir,
]

executable('textpieces', textpieces_sources,
  vala_args: vala_args, c_args: c_args,
  dependencies: textpieces_deps,
  install: true,
)
