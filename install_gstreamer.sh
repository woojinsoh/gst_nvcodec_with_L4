#!/bin/bash
set -a

apt-get update
apt-get install -y flex bison
pip3 install meson

export PATH=~/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH

git clone https://gitlab.freedesktop.org/gstreamer/gst-build.git
cd gst-build&&git checkout 1.19.2

meson build
ninja -C build
ninja -C build install
ldconfig
