project('textpieces', ['c', 'vala'],
          version: '3.0.2',
    meson_version: '>= 0.59.0',
  default_options: [ 'warning_level=2',
                   ],
)

# Get package data directory (usually /usr/share/textpieces)
pkgdata_dir = get_option('prefix') / get_option('datadir') / meson.project_name()

textpieces_sources = []

valac = meson.get_compiler('vala')
vapi_dir = join_paths (meson.project_source_root(), 'src', 'vapi')

add_project_arguments(
  [
    '--target-glib=2.50',
    '--enable-experimental',
    '--vapidir', vapi_dir,
  ],
  language: 'vala'
)

# Dependencies {

libadwaita_dep = dependency('libadwaita-1', version: '>= 1.0.0-alpha.2', required: false)
if not libadwaita_dep.found()
  libadwaita = subproject(
    'libadwaita',
    default_options: [
      'examples=false',
      'package_subdir=@0@'.format(meson.project_name()),
      'tests=false'
    ]
  )
  libadwaita_dep = declare_dependency(
    dependencies: [
      libadwaita.get_variable('libadwaita_dep'),
      libadwaita.get_variable('libadwaita_vapi')
    ]
  )
endif

gtksourceview_dep = dependency('gtksourceview-5', version: '>= 5.0.0', required: false)
if not gtksourceview_dep.found()
  gtksourceview = subproject(
    'gtksourceview',
    default_options: [
      'package_subdir=@0@'.format(meson.project_name()),
      'tests=false'
    ]
  )
  gtksourceview_dep = declare_dependency(
    dependencies: [
      gtksourceview.get_variable('gtksource_dep'),
      gtksourceview.get_variable('gtksource_vapi')
    ]
  )
endif

json_glib_dep = dependency('json-glib-1.0', version: '>= 1.6.0', required: false)
if not gtksourceview_dep.found()
  json_glib = subproject(
    'json-glib',
    default_options: [
      'package_subdir=@0@'.format(meson.project_name()),
      'tests=false',
      'gtk_doc=disabled',
      'introspection=enabled'
    ]
  )
  json_glib_dep = declare_dependency(
    dependencies: [
      json_glib.get_variable('json_glib_dep'),
      json_glib.get_variable('json_glib_gir')
    ]
  )
endif

textpieces_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gio-unix-2.0', version: '>= 2.50'),
  dependency('gtk4', version: '>= 4.2'),
  json_glib_dep,
  gtksourceview_dep,
  libadwaita_dep,
  valac.find_library('config', dirs: vapi_dir),
]

# }

i18n = import('i18n')
gnome = import('gnome')

subdir('data')
subdir('resources')
subdir('src')
subdir('po')

install_subdir('scripts', install_dir: pkgdata_dir)

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true
)