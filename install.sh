#!/bin/bash

# This script provides instructions on how to install the icecube-simulation framework
# with monopole-generator on macOS.
# https://github.com/fiedl/monopole-generator-install

# In order to separate out several build steps with github actions, I'm using the
# `BUILD_STEP` enviornment variable. When using these instructions on your local machine,
# you don't need the `BUILD_STEP` environment variable.

# Before executing this script, install the icecube-simulation framework
# without monopole-generator from these instructions:
# https://github.com/fiedl/icecube-simulation-install/blob/master/install.sh


# Homebrew paths
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# Python path when installed via homebrew
export PATH=/usr/local/opt/python/libexec/bin:$PATH


# This is where the icecube software will live
export ICECUBE_ROOT="$HOME/icecube/software"

# If you would like to use a release, set the `RELEASE` environment variable
# to the appropriate icecube-simulation release number.
#
#     export RELEASE=V06-01-01
#
# If you would like to use the current `svn trunk`, set the `RELEASE` environment
# variable to "trunk".
#
#     export RELEASE=trunk
#
# In this repository, the `RELEASE` environment varibale is set by the
# github-actions build matrix.
[[ -z "$RELEASE" ]] && echo "Please set the RELEASE environment variable, e.g.: 'export RELEASE=V06-01-01' or 'export RELEASE=trunk'." && exit 1

export ICESIM_ROOT=$ICECUBE_ROOT/icecube-simulation-$RELEASE
export ICESIM=$ICESIM_ROOT/debug_build

if [[ ! -z "$BUILD_STEP" ]] && [[ $BUILD_STEP = "ICECUBE_SIMULATION_BUILD" ]]; then

  # Following the generic icecube-simulation install instructions from:
  # https://github.com/fiedl/icecube-simulation-install

  curl https://raw.githubusercontent.com/fiedl/icecube-simulation-install/master/install.sh | bash -v -e

fi
if [[ ! -z "$BUILD_STEP" ]] && [[ $BUILD_STEP = "MONOPOLE_GENERATOR_BUILD" ]]; then

  # Get the monopole-generator code
  if [ ! -d $ICESIM_ROOT/src/monopole-generator ]; then
    if [[ -z $SVN_ICECUBE_USERNAME ]]; then
      source .secrets.sh
    fi
    svn --username $SVN_ICECUBE_USERNAME --password $SVN_ICECUBE_PASSWORD co $SVN/projects/monopole-generator/trunk/ $ICESIM_ROOT/src/monopole-generator
    cd $ICESIM_ROOT/debug_build
    cmake -D CMAKE_BUILD_TYPE=Debug -D SYSTEM_PACKAGES=true -D CMAKE_BUILD_TYPE:STRING=Debug ../src
    make
  fi

fi
if [[ ! -z "$BUILD_STEP" ]] && [[ $BUILD_STEP = "BUILD_TEST_BINS" ]]; then

  cd $ICESIM_ROOT/debug_build
  make test-bins

fi
if [[ ! -z "$BUILD_STEP" ]] && [[ $BUILD_STEP = "MONOPOLE_GENERATOR_TESTS" ]]; then

  cd $ICESIM_ROOT/debug_build
  bin/monopole-generator-test -a

fi

