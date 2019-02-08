# CI scripts for GAP packages

This repository contains scripts which GAP package can use to implement
continuous integration test with e.g. Travis CI.

These scripts are normally placed in subdirectory `scripts` or `etc` in
the package. Examples for suitable `.travis.yml` and `.codecov.yml` files
can be found in the `examples` branch of this repository.


## Initial setup

TODO: explain how to use the code into the repository;
and then how to setup Travis (this probably should also cover how to enable
Travis CI integration on their website for packages which are not hosted
in the `gap-packages` github organization)


## Upgrading to a newer version

TODO: decide how to do this: use subtree merges? Or perhaps we should remove those
`scripts` dirs, and instead each `.travis.yml` should start with

    git clone https://github.com/gap-system/pkg-ci-scripts.git scripts


## Example Travis CI integration

Example content for `.travis.yml`
```
language: c
env:
  global:
    - GAPROOT=gaproot
    - COVDIR=coverage
    - GAP_PKGS_TO_CLONE="rcwa"
    - GAP_PKGS_TO_BUILD="io profiling"  # optional

addons:
  apt_packages:
    - libgmp-dev
    - libreadline-dev

matrix:
  include:
    - env: GAPBRANCH="master"
    - env: GAPBRANCH="stable-4.9"
    - env: GAPBRANCH="stable-4.10"

branches:
  only:
    - master

before_script:
  - export GAPROOT="$HOME/gap"
  - git clone https://github.com/gap-system/pkg-ci-scripts.git scripts
  - scripts/build_gap.sh
script:
  - scripts/build_pkg.sh && scripts/run_tests.sh
after_script:
  - bash scripts/gather-coverage.sh
  - bash <(curl -s https://codecov.io/bash)
```


## FAQ

### Q: How can I ensure other required GAP packages get compiled?

A: Set the `GAP_PKGS_TO_BUILD` environment variable before running
`build_gap.sh` to a string listing the (start of the) directory names of
the packages you need compiled. Make sure to always include `io` and
`profiling` in this list, as these are needed for generating code
coverage.

Example: If you need the `cvec` package, you can add this in a
suitable place in your `.travis.yml`:

    GAP_PKGS_TO_BUILD="io profiling cvec"

Then this will compile all packages whose package directory name starts with
"io", "profiling" or "cvec". This "starts with" rule is intended to support
packages where the directory name contains the version.


### Q: How can I install a development version of another package needed for the CI tests?

A: If you need the latest development version of another package in
order for your CI tests to run successfully, this can be achieved by
setting the `GAP_PKGS_TO_CLONE` environment variable to a list of package
names or URLs, separated by spaces. For example, if you set

    GAP_PKGS_TO_CLONE="mypkg1 myuser/mypkg2 https://gitlab.com/myuser/mypkg3"

This will clone packages from the following three URLs:
  - https://github.com/gap-packages/mypkg1
  - https://github.com/myuser/mypkg2
  - https://gitlab.com/myuser/mypkg3

Don't forget to also add any package that needs to be compiled to `GAP_PKGS_TO_BUILD`.


### Q: How can I enable (or disable) code coverage reporting?

TODO: mention `.codecov.yml` (perhaps also Coveralls); also `NO_COVERAGE`


## Contact

Please submit bug reports, suggestions for improvements and patches via
the [issue tracker](https://github.com/pkg-ci-scripts/ReleaseTools/issues).


## Copyright and license

Copyright (C) 2017-2019 Max Horn
Copyright (C) 2017-2019 The GAP Team

This code is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

For details see the file COPYING.
