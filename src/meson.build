textpieces_sources = [
  'main.vala',
  'window.vala',
  'tool-row.vala',
]

textpieces_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gee-0.8', version: '>= 0.20'),
]

gnome = import('gnome')

textpieces_sources += gnome.compile_resources('textpieces-resources',
  'textpieces.gresource.xml',
  c_name: 'textpieces'
)

executable('textpieces', textpieces_sources,
  vala_args: '--target-glib=2.50',  dependencies: textpieces_deps,
  install: true,
)
