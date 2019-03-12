#!/usr/bin/env bash
#
# Copyright (C) 2017-2019 Max Horn
# Copyright (C) 2017-2019 The GAP Team
# 
# This code is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
set -ex

GAPROOT=${GAPROOT-$HOME/gap}

# ensure coverage is turned on
export CFLAGS="$CFLAGS --coverage"
export CXXFLAGS="$CXXFLAGS --coverage"
export LDFLAGS="$LDFLAGS --coverage"

# adjust build flags for 32bit builds
if [[ $ABI = 32 ]]; then
    export CFLAGS="$CFLAGS -m32"
    export CXXFLAGS="$CXXFLAGS -m32"
    export LDFLAGS="$LDFLAGS -m32"
fi

# build this package, if necessary
if [[ -x autogen.sh ]]; then
    ./autogen.sh
    ./configure --with-gaproot=$GAPROOT
    make -j4 V=1
elif [[ -x configure ]]; then
    ./configure $GAPROOT
    make -j4 CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS"
fi

# set up a custom GAP root containing only this package, so that
# we can force GAP to load the correct version of this package
mkdir -p gaproot/pkg/
ln -f -s $PWD gaproot/pkg/
