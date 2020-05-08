#!/bin/bash
set -e

if [ ! -d "build" ]; then
	meson --prefix=/usr build
fi
ninja -C build
sudo ninja install -C build
