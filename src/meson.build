textpieces_sources = [
  'main.vala',
  'window.vala',
  'tool-row.vala',
  'shortcuts.vala',
  'preferences.vala',
]

textpieces_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gee-0.8', version: '>= 0.20'),
  dependency('gtksourceview-4', version: '>= 4.8'),
  dependency('libhandy-1', version: '>= 1.0.3'),
]

gnome = import('gnome')

textpieces_sources += gnome.compile_resources('textpieces-resources',
  join_paths('resources', 'textpieces.gresource.xml'),
  source_dir: 'resources',
  c_name: 'textpieces',
)

executable('textpieces', textpieces_sources,
  vala_args: '--target-glib=2.50',  dependencies: textpieces_deps,
  install: true,
)
