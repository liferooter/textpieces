project('textpieces', ['c', 'vala'],
          version: '1.3.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)
textpieces_sources = []

valac = meson.get_compiler('vala')
vapi_dir = join_paths (meson.source_root(), 'src', 'vapis')

# Dependencies {

libadwaita_dep = dependency('libadwaita-1', version: '>= 1.0.0-alpha', required: false)
if not libadwaita_dep.found()
libadwaita = subproject(
  'libadwaita',
  install: false,
  default_options: [
    'examples=false',
    'package_subdir=my-project-name',
    'tests=false',
  ]
)
libadwaita_dep = libadwaita.get_variable('libadwaita_dep')
endif

gtksource_dep = dependency('gtksourceview-5', version: '>= 5.0.0', required: true)
if not gtksource_dep.found()
gtksourceview = subproject(
  'gtksourceview',
  install: false,
  default_options: [
    'examples=false',
    'package_subdir=my-project-name',
    'tests=false',
  ]
)
gtksource_dep = gtksourceview.get_variable('gtksource_dep')
endif

textpieces_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('json-glib-1.0', version: '>= 1.6.2'),
  gtksource_dep,
  libadwaita_dep,
  valac.find_library('config', dirs: vapi_dir),
]

# }

i18n = import('i18n')

subdir('data')
subdir('src')
subdir('po')

install_subdir('scripts', install_dir: get_option('datadir'),
               install_mode: 'rwxr-xr-x')

meson.add_install_script('build-aux/meson/postinstall.py')
