# Notes on building the Software Stack for JEDI applications on Mac OS

Building the JEDI software stack on Mac OS (*catalina 10.15.7 and newer*) is described in some detail elsewhere, in particular:

[Minimum steps for working with JEDI natively on Mac OS](https://github.com/JCSDA-internal/jedi-docs/blob/develop/howto/macos/minimum.md)

The [brew](https://brew.sh) package manager installs packages to their own directory (/usr/local/Cellar/\<package\>) and then symlinks their files into the system location /usr/local. There are exceptions: Sometimes, brew cannot symlink to header files or libraries in /usr/local, and
for some packages that have multiple related components, they are not installed in a common root location in /usr/local/Cellar.

If you are building the optional jedi-stack component [ecFlow](https://confluence.ecmwf.int/display/ECFLOW/ecflow+home), two scripts are provided to properly symlink software packages that ecFlow requires:

| software  | helper script | Notes |
| -------   | --------------- | ----- |
| openssl   | linkOpenSSLmacOS.sh | backs up deprecated versions of system libraries and symlinks to brew's version |
| boost / boost-python3 | co-locates boost and boost-python libraries, allowing you to set the build config variable BOOST_ROOT |

Running these scripts after installing openssl and boost / boost-python3 will properly set up symlinks for jedi-stack components that depend on them to build correctly.
