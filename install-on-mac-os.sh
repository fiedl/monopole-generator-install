#!/bin/bash

# This script provides instructions on how to install the icecube-simulation framework on macOS.
# https://github.com/fiedl/hole-ice-install

# In order to separate out several build steps with github actions, I'm using the
# `BUILD_STEP` enviornment variable. When using these instructions on your local machine,
# you don't need the `BUILD_STEP` environment variable.


# Homebrew paths
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# Python path when installed via homebrew
export PATH=/usr/local/opt/python/libexec/bin:$PATH


if [[ ! -z "$BUILD_STEP" ]] && [[ $BUILD_STEP = "SYSTEM_PACKAGES" ]]; then

  # Install Homebrew package manager (http://brew.sh):
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  # Install python 3
  brew info python
  brew install python

  # Install boost with python bindings
  brew info boost
  brew install fiedl/homebrew-icecube/boost@1.69
  brew info boost-python
  brew info boost-python3
  brew install fiedl/homebrew-icecube/boost-python3@1.69

  # Install python packages
  pip install numpy
  pip install scipy

  # Install packages needed for building icecube-simulation
  brew install cmake gsl cfitsio

  # Install qt5 needed for steamshovel event display viewer
  brew info qt
  brew install qt
  #brew install pyqt

  ## Install packages from icecube sources, e.g. random number generator
  #brew tap IceCube-SPNO/homebrew-icecube
  #brew install pal sprng2 cppzmq

fi

# This is where the icecube software will live
export ICECUBE_ROOT="$HOME/icecube/software"

# If you want to use a release:
export RELEASE=V06-01-01
export ICESIM_ROOT=$ICECUBE_ROOT/icecube-simulation-$RELEASE
export ICESIM=$ICESIM_ROOT/debug_build

# # If you want to use the trunk:
# export CURRENT_TRUNK=2016-02-02
# export ICESIM_ROOT=$ICECUBE_ROOT/simulation-trunk-$CURRENT_TRUNK
# export ICESIM=$ICESIM_ROOT/debug_build

if [[ ! -z "$BUILD_STEP" ]] && [[ $BUILD_STEP = "ICECUBE_SIMULATION_BUILD" ]]; then

  # Get icecube-simulation code from svn repository
  mkdir -p $ICESIM_ROOT
  if [ ! -d $ICESIM_ROOT/src ]; then
    if [[ -z $SVN_ICECUBE_USERNAME ]]; then
      source .secrets.sh
    fi
    svn --username $SVN_ICECUBE_USERNAME --password $SVN_ICECUBE_PASSWORD co $SVN/meta-projects/simulation/releases/$RELEASE/ $ICESIM_ROOT/src
  fi

  # Get the monopole-generator code
  if [ ! -d $ICESIM_ROOT/src/monopole-generator ]; then
    if [[ -z $SVN_ICECUBE_USERNAME ]]; then
      source .secrets.sh
    fi
    svn --username $SVN_ICECUBE_USERNAME --password $SVN_ICECUBE_PASSWORD co $SVN/projects/monopole-generator/trunk/ $ICESIM_ROOT/src/monopole-generator
  fi

  # Exclude projects if requested by environment variable,
  # which is used on travis to avoid the execution-time limit
  if [[ ! -z $EXCLUDE_PROJECTS ]]; then
    for project in $EXCLUDE_PROJECTS; do
      rm -rf $ICESIM_ROOT/src/$project
    done
  fi

  # Patch cmake file to find pymalloc version of python installed by homebrew
  # https://github.com/fiedl/hole-ice-install/issues/1
  patch --force $ICESIM_ROOT/src/cmake/tools/python.cmake < ./patches/python.cmake.patch

  # Patch muongun pybindings to add missing static cast
  # https://github.com/fiedl/hole-ice-install/issues/2
  if [[ -d $ICESIM_ROOT/src/MuonGun ]]; then
    patch --force $ICESIM_ROOT/src/MuonGun/private/pybindings/histogram.cxx < ./patches/muongun-histogram.cxx.patch
  fi

  # Patch cmake file to drop requirement of the boost_signals library,
  # which has been dropped in boost 1.69
  # https://github.com/fiedl/hole-ice-install/issues/3
  # https://code.icecube.wisc.edu/projects/icecube/ticket/2232
  patch --force $ICESIM_ROOT/src/cmake/tools/boost.cmake < ./patches/boost.cmake.patch

  # Build the release (debug)
  mkdir -p $ICESIM_ROOT/debug_build
  cd $ICESIM_ROOT/debug_build
  cmake -D CMAKE_BUILD_TYPE=Debug -D SYSTEM_PACKAGES=true -D CMAKE_BUILD_TYPE:STRING=Debug ../src
  # source ./env-shell.sh  # <--- is this needed here?
  make -j 6

  # # Build the release
  # mkdir -p $ICESIM_ROOT/build
  # cd $ICESIM_ROOT/build
  # cmake -D CMAKE_BUILD_TYPE=Release -D SYSTEM_PACKAGES=true -D CMAKE_BUILD_TYPE:STRING=Release ../src
  # ./env-shell.sh
  # make -j 2

fi
if [[ ! -z "$BUILD_STEP" ]] && [[ $BUILD_STEP = "CLSIM_WITH_HOLE_ICE" ]]; then

  # Get clsim fork with hole ice
  # https://github.com/fiedl/clsim
  rm -r $ICESIM_ROOT/src/clsim
  git clone https://github.com/fiedl/clsim.git $ICESIM_ROOT/src/clsim
  cd $ICESIM_ROOT/debug_build
  make

fi

# Make sure to deactivate opencl kernel caching.
# See: https://github.com/fiedl/hole-ice-study/issues/15
export CUDA_CACHE_DISABLE=1

