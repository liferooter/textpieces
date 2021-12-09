textpieces_sources += [
  'Application.vala',
  'Window.vala',
  'Preferences.vala',
  'Tool.vala',
  'ToolsController.vala',
  'ToolSettings.vala',
  'CustomToolPage.vala',
  'NewToolPage.vala',
  'Search.vala',
  'Utils.vala'
]

executable('textpieces', textpieces_sources,
  c_args: [
    '-DVERSION="' + meson.project_version() + '"',
    '-DPKGDATADIR="' + pkgdata_dir + '"',
    '-DSCRIPTDIR="' +  pkgdata_dir / 'scripts' + '"',
    '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
    '-DGNOMELOCALEDIR="' + get_option('prefix') / get_option('localedir') + '"',
  ],
  dependencies: textpieces_deps,
  install: true,
)
