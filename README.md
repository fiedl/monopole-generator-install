# Hole-Ice-Install

[![Build Status](https://github.com/fiedl/hole-ice-install/workflows/CI/badge.svg)](https://github.com/fiedl/hole-ice-install/actions)

This repository provides reproducible install instructions for the hole-ice code and the icecube-simulation framework related to https://github.com/fiedl/hole-ice-study and https://github.com/fiedl/hole-ice-scripts.

## Installation on macOS

The file [install-on-mac-os.sh](install-on-mac-os.sh) contains instructions on how to install the icecube-simulation framework with the hole-ice additions on macOS.

## Automated Build Using Vagrant

In order to have the install scriot run on a virtual machine, this repository provides [Vagrant](http://vagrantup.com) instructions in the [Vagrantfile](Vagrantfile).

```bash
# Clone this repository
git clone git@github.com:fiedl/hole-ice-install.git
```

For the automated code checkout to work, you need to provide svn credentials in a secrets file, which is not included in this repository. Please create the following file and provide credentials there:

```bash
# .secrets.sh
export SVN="our svn url"
export SVN_ICECUBE_USERNAME="our svn username"
export SVN_ICECUBE_PASSWORD="our svn password"
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

- [IceCube documentation on installing on OS X with Python 2](http://software.icecube.wisc.edu/documentation/projects/cmake/supported_platforms/osx.html)
- [Installing icecube-simulation V05-00-07 with Python 2 on macOS Sierra](https://github.com/fiedl/hole-ice-study/blob/master/notes/2016-11-15_Installing_IceSim_on_macOS_Sierra.md)
- [Installing icecube-simulation V05-00-07 with Python 2 in Zeuthen](https://github.com/fiedl/hole-ice-study/blob/master/notes/2018-01-23_Installing_IceSim_in_Zeuthen.md)
- Hole-ice study: https://github.com/fiedl/hole-ice-study
- Hole-ice example scripts: https://github.com/fiedl/hole-ice-scripts
