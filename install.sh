#!/bin/bash
set -e

#meson --prefix=/usr build
ninja -C build
sudo ninja install -C build