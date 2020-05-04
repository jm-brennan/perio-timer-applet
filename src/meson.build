gnome = import('gnome')

custom_target(
    'plugin-file-pattern-timer',
    input: 'PatternTimer.plugin.in',
    output: 'PatternTimer.plugin',
    command : [intltool, '--desktop-style', podir, '@INPUT@', '@OUTPUT@'],
    install: true,
    install_dir: APPLET_INSTALL_DIR
)

data_dir = join_paths(meson.source_root(), 'data')

#gresource_file = join_paths(data_dir, 'com.github.EbonJaeger.budgie-trash-applet.gresource.xml')
#res = gnome.compile_resources('bta-resources', gresource_file, source_dir: data_dir)

applet_deps = [
    dep_budgie,
    dep_gtk3,
    dep_glib
]

applet_sources =[
    'PatternTimer.vala',
    'Widgets/MainPopover.vala'
]

vala_args = [
    '--pkg', 'gtk+-3.0',
    '--pkg', 'glib-2.0'
]

shared_library(
    'patterntimer',
    applet_sources,
    dependencies: applet_deps,
    vala_args: vala_args,
    install: true,
    install_dir: APPLET_INSTALL_DIR
)
