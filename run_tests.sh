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

# set up a custom GAP root containing only this package, so that
# we can force GAP to load the correct version of this package
# (we already did that in build_pkg.sh, but we do it again here,
# to allow the occasional instance where a package wants to also
# run the tests of others packages, by invoking this script multiple
# times in different directories)
mkdir -p gaproot/pkg/
ln -f -s $PWD gaproot/pkg/

# start GAP with custom GAP root, to ensure correct package version is loaded
GAP="$GAPROOT/bin/gap.sh -l $PWD/gaproot; --quitonbreak"

# Unless explicitly turned off by setting the NO_COVERAGE environment variable,
# we collect coverage data
if [[ -z $NO_COVERAGE ]]; then
    mkdir -p ${COVDIR-coverage}
    GAP="$GAP --cover ${COVDIR-coverage}/$(mktemp XXXXXX).coverage"
fi

$GAP $GAP_FLAGS <<GAPInput
info := "PackageInfo.g";
if IsReadableFile( info ) then
    Unbind( GAPInfo.PackageInfoCurrent );
    Read( info );
    if IsBound( GAPInfo.PackageInfoCurrent ) then
        record := GAPInfo.PackageInfoCurrent;
        Unbind( GAPInfo.PackageInfoCurrent );
    else
        Error( "Something is wrong with PackageInfo.g" );
    fi;
else
    Error( "PackageInfo.g is not readable" );
fi;

# Decide which packages should be loaded
# Default is all necessary & suggested packages
if $ALL_PACKAGES then
    LoadAllPackages();
elif $ONLY_NEEDED then
    LoadPackage( record.PackageName : OnlyNeeded );
else
    LoadPackage( record.PackageName );
fi;

# Decide which test file should be used
# Default is test file listed in PackageInfo.g
if IsEmpty("${GAP_TESTFILE}") then
    testFile := record.TestFile;
else
    testFile := "${GAP_TESTFILE}";
fi;

Read( testFile );
GAPInput
