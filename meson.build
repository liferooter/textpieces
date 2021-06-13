project('textpieces', ['c', 'vala'],
          version: '1.3.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)
textpieces_sources = []

textpieces_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gtksourceview-4', version: '>= 4.8'),
  dependency('libhandy-1', version: '>= 1.0.3'),
  dependency('json-glib-1.0', version: '>= 1.6.2'),
  valac.find_library('config', dirs: vapi_dir),
]

i18n = import('i18n')

valac = meson.get_compiler('vala')
vapi_dir = join_paths (meson.source_root(), 'src', 'vapis')

subdir('data')
subdir('src')
subdir('po')

install_subdir('scripts', install_dir: get_option('datadir'),
               install_mode: 'rwxr-xr-x')

meson.add_install_script('build-aux/meson/postinstall.py')
