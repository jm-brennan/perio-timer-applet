project('perio-timer',
        ['vala', 'c'],
        version: '0.1'
)

# Dependencies
dep_budgie = dependency('budgie-1.0', version: '>= 2')
dep_gtk3 = dependency('gtk+-3.0', version: '>= 3.22.0')
dep_glib = dependency('glib-2.0', version: '>= 2.46.0')
dep_json = dependency('json-glib-1.0', version: '>=1.0')

intltool = find_program('intltool-merge')

# Global stuff
prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))
localedir = join_paths(prefix, get_option('localedir'))
podir = join_paths(meson.source_root(), 'po')

APPLET_INSTALL_DIR = join_paths(libdir, 'budgie-desktop', 'plugins', meson.project_name())

gnome = import('gnome')
gresources = gnome.compile_resources(
    'project-resources',
    'data/gresources.xml',
    source_dir: ['data']
)

subdir('src')
subdir('data')
