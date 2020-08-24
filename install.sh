#!/bin/bash
set -e

if [ -d "build" ]; then
	rm -rf build
fi
meson --prefix=/usr build
ninja -C build
sudo ninja install -C build
