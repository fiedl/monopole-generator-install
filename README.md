# Monopole-Generator-Install

[![Build Status](https://github.com/fiedl/monopole-generator-install/workflows/CI/badge.svg)](https://github.com/fiedl/monopole-generator-install/actions)

This repository provides reproducible install instructions for the monopole-generator code and the icecube-combo framework.

## Installation

The file [install.sh](install.sh) contains instructions on how to install the icecube-combo framework with monopole-generator on macOS and ubuntu.

## Automated Build Using Vagrant

In order to have the install script run on a virtual machine, this repository provides [Vagrant](http://vagrantup.com) instructions in the [Vagrantfile](Vagrantfile).

```bash
# Clone this repository
git clone git@github.com:fiedl/monopole-generator-install.git
```

For the automated code checkout to work, you need to provide svn credentials in a secrets file, which is not included in this repository. Please create the following file and provide credentials there:

```bash
# .secrets.sh
export COMBO_GIT_SOURCE="https://username:token@github.com/.../IceTrayCombo.git"
export MONOPOLE_GENERATOR_GIT_SOURCE="https://username:token@github.com/.../monopole-generator.git"
```

After that, install and run vagrant:

```bash
# Install Vagrant
brew cask instal vagrant

# Start the virtual machine and run the install instructions
vagrant up
```

After changing the install scripts, rerun via `vagrant provision` or `vagrant reload --provision`.

## Additional Resources

- https://github.com/fiedl/icecube-combo-install
- Based on: Install instructions for hole-ice clsim: https://github.com/fiedl/hole-ice-install
- [IceCube documentation on installing on OS X with Python 2](http://software.icecube.wisc.edu/documentation/projects/cmake/supported_platforms/osx.html)
- [Installing icecube-simulation V05-00-07 with Python 2 on macOS Sierra](https://github.com/fiedl/hole-ice-study/blob/master/notes/2016-11-15_Installing_IceSim_on_macOS_Sierra.md)
- [Installing icecube-simulation V05-00-07 with Python 2 in Zeuthen](https://github.com/fiedl/hole-ice-study/blob/master/notes/2018-01-23_Installing_IceSim_in_Zeuthen.md)
