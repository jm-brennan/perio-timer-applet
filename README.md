# perio-timer-applet
Applet is still under heavy development. Basic functionality (operated through keyboard) shown here:
<p align="center">
  <img src="data/style/demo.GIF" alt="Timer Demonstration"/>
</p>


## Motivation
If you need a timer, that means you are doing something else. That sounds dumb, but it helps to point out that setting up a timer should be as easy as possible so you can focus on the real work. I got tired of having browser tabs or other full apps that required extra mental space, keypresses, and mouse clicks to use. They were also never as customizable nor as flexible as I believe a timer application should be. So I made this.

### Perio Timer allows you to:
- Easily create both simple and complex timers
- Have multiple stages within a timer
- Continually repeat a timer after its completion
- Customize colors and sounds
- Choose how you want to be notified upon timer completion
- Not have to specify seconds by default

The goal is for Perio Timer to work just as easily for the most complex pomodoro routines as well as a simple 5 minute timer.

</br>

# Installation
To install this applet, be sure to have these dependencies:</br>
```
budgie-desktop-devel
glib2-devel
libgtk-3-devel
libjson-glib-devel
vala
meson
pulseaudio
system.devel (pass -c to eopkg install)
```

and then run these commands to:

Make the Meson build directory
```
mkdir build
meson --prefix=/usr build
```

Build the applet
```
ninja -C build
```

Install the applet
```
sudo ninja install -C build
```

Refresh Budgie
```
nohup budgie-panel --replace &
```

Then, open the Budgie desktop settings and install to your panel.

</br>

# How To Use
See the <a href="https://github.com/jm-brennan/perio-timer-applet/blob/master/GUIDE.md">usage guide</a>

