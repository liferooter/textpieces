project('textpieces', ['c', 'vala'],
          version: '2.1.2',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)

pkgdata_dir = get_option('prefix') / get_option('datadir') / meson.project_name()

textpieces_sources = []

valac = meson.get_compiler('vala')
vapi_dir = join_paths (meson.source_root(), 'src', 'vapi')

# Dependencies {

libadwaita_dep = dependency('libadwaita-1', version: '>= 1.0.0-alpha', required: false)
if not libadwaita_dep.found()
libadwaita = subproject(
  'libadwaita',
  install: false,
  default_options: [
    'examples=false',
    'package_subdir=' + meson.project_name(),
    'tests=false',
  ]
)
libadwaita_dep = libadwaita.get_variable('libadwaita_dep')
endif

gtksource_dep = dependency('gtksourceview-5', version: '>= 5.0.0', required: false)
if not gtksource_dep.found()
gtksourceview = subproject(
  'gtksourceview',
  install: false,
  default_options: [
    'examples=false',
    'package_subdir=' + meson.project_name(),
    'tests=false',
  ]
)
gtksource_dep = gtksourceview.get_variable('gtksource_dep')
endif

textpieces_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gio-unix-2.0', version: '>= 2.50'),
  dependency('gtk4', version: '>= 4.2'),
  dependency('json-glib-1.0', version: '>= 1.6.2'),
  gtksource_dep,
  libadwaita_dep,
  valac.find_library('config', dirs: vapi_dir),
]

# }

i18n = import('i18n')

subdir('data')
subdir('resources')
subdir('src')
subdir('po')

install_subdir('scripts', install_dir: pkgdata_dir)

meson.add_install_script('build-aux/meson/postinstall.py')
