project('textpieces', ['c', 'vala'],
          version: '1.1.3',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)
textpieces_sources = []

i18n = import('i18n')

valac = meson.get_compiler('vala')
vapi_dir = join_paths (meson.source_root(), 'src', 'vapis')

subdir('data')
subdir('src')
subdir('po')

install_subdir('scripts', install_dir: get_option('datadir'),
               install_mode: 'rwxr-xr-x')

meson.add_install_script('build-aux/meson/postinstall.py')
