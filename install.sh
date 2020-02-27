#!/bin/bash

# This script provides instructions on how to install the icecube-combo framework
# with monopole-generator on macOS or ubuntu.
# https://github.com/fiedl/monopole-generator-install

# In order to separate out several build steps with github actions, I'm using the
# `BUILD_STEP` enviornment variable. When using these instructions on your local machine,
# you don't need the `BUILD_STEP` environment variable.

# Before executing this script, install the icecube-combo framework
# without monopole-generator from these instructions:
# https://github.com/fiedl/icecube-combo-install/blob/master/install.sh


# Homebrew paths
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# Python path when installed via homebrew
export PATH=/usr/local/opt/python/libexec/bin:$PATH

# Get repo paths from secrets file locally
if [[ -z $SVN_ICECUBE_USERNAME ]] && [[ -z $COMBO_GIT_SOURCE ]]; then
  source .secrets.sh
fi

# This is where the icecube software will live
export ICECUBE_ROOT="$HOME/icecube/software"
export ICECUBE_COMBO_ROOT=$ICECUBE_ROOT/combo
export ICECUBE_COMBO_SRC=$ICECUBE_COMBO_ROOT/src
export ICECUBE_COMBO_BUILD=$ICECUBE_COMBO_ROOT/build

if [[ -z "$BUILD_STEP" ]] || [[ $BUILD_STEP = "ICECUBE_SIMULATION_BUILD" ]]; then

  # Following the generic icecube-combo install instructions from:
  # https://github.com/fiedl/icecube-combo-install

  export GIT_REPO_URL=$COMBO_GIT_SOURCE
  curl https://raw.githubusercontent.com/fiedl/icecube-combo-install/master/install.sh | bash -v -e

fi
if [[ -z "$BUILD_STEP" ]] || [[ $BUILD_STEP = "MONOPOLE_GENERATOR_BUILD" ]]; then

  # Get the monopole-generator code
  if [ ! -d $ICECUBE_COMBO_SRC/monopole-generator ]; then
    git clone $MONOPOLE_GENERATOR_GIT_SOURCE $ICECUBE_COMBO_SRC/monopole-generator --branch fiedl/review-fixes
  fi

  cd $ICECUBE_COMBO_BUILD
  cmake -D CMAKE_BUILD_TYPE=Debug -D SYSTEM_PACKAGES=true -D CMAKE_BUILD_TYPE:STRING=Debug $ICECUBE_COMBO_SRC
  ./env-shell.sh make

fi
if [[ -z "$BUILD_STEP" ]] || [[ $BUILD_STEP = "BUILD_TEST_BINS" ]]; then

  cd $ICECUBE_COMBO_BUILD
  ./env-shell.sh bash -c "env && cd monopole-generator && make monopole-generator-test"

fi
if [[ -z "$BUILD_STEP" ]] || [[ $BUILD_STEP = "MONOPOLE_GENERATOR_PYTHON_TESTS" ]]; then

  cd $ICECUBE_COMBO_BUILD
  ./env-shell.sh python $ICECUBE_COMBO_SRC/monopole-generator/resources/test/test_monopole_generator.py
  ./env-shell.sh python $ICECUBE_COMBO_SRC/monopole-generator/resources/test/test_monopole_propagator.py

fi
if [[ -z "$BUILD_STEP" ]] || [[ $BUILD_STEP = "MONOPOLE_GENERATOR_TESTS" ]]; then

  cd $ICECUBE_COMBO_BUILD
  ./env-shell.sh bin/monopole-generator-test -a

fi

