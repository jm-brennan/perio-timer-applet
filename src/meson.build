gnome = import('gnome')

custom_target(
    'plugin-file-perio-timer',
    input: 'PerioTimer.plugin.in',
    output: 'PerioTimer.plugin',
    command : [intltool, '--desktop-style', podir, '@INPUT@', '@OUTPUT@'],
    install: true,
    install_dir: APPLET_INSTALL_DIR
)

applet_deps = [
    dep_budgie,
    dep_gtk3,
    dep_glib,
    dep_json
]

applet_sources =[
    'PerioTimerApplet.vala',
    'Widgets/PTimer.vala',
    'Widgets/Stage.vala',
    'Widgets/MainPopover.vala',
    'Widgets/TimerAnimation.vala',
    'Widgets/InputManager.vala',
    'Widgets/Colors.vala',
    gresources
]

vala_args = [
    '--pkg', 'gtk+-3.0',
    '--pkg', 'glib-2.0',
    '--pkg', 'json-glib-1.0'
]

shared_library(
    'periotimer',
    applet_sources,
    dependencies: applet_deps,
    vala_args: vala_args,
    install: true,
    install_dir: APPLET_INSTALL_DIR
)
