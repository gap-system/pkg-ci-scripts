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

# If we don't care about code coverage, do nothing
if [[ -n $NO_COVERAGE ]]; then
    exit 0
fi

GAPROOT=${GAPROOT-$HOME/gap}

# start GAP with custom GAP root, to ensure correct package version is loaded
GAP="$GAPROOT/bin/gap.sh -l $PWD/gaproot; --quitonbreak -q"

# generate library coverage reports
$GAP -a 500M -m 500M -q <<GAPInput
if LoadPackage("profiling") <> true then
    Print("ERROR: could not load profiling package");
    FORCE_QUIT_GAP(1);
fi;
d := Directory("${COVDIR-coverage}");;
covs := [];;
for f in DirectoryContents(d) do
    if f in [".", ".."] then continue; fi;
    Add(covs, Filename(d, f));
od;
Print("Merging coverage results from ", covs, "\n");
r := MergeLineByLineProfiles(covs);;
# filtered out unwanted other packages to avoid bad coverage interaction
r.line_info := Filtered(r.line_info, x -> not StartsWith( x[1], "$HOME/gap/" ) );;
Print("Outputting JSON\n");
OutputJsonCoverage(r, "gap-coverage.json");;
QUIT_GAP(0);
GAPInput

# generate source coverage reports by running gcov
gcov -o . $(git ls-files :*.c :*.cc :*.cpp :*.C)
