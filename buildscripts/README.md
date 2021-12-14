For now we are treating the `libs/build_*.sh` scripts as machine independent.
For example the `module try_load ncarcompilers` command in many of the scripts is only relevant on NCAR platforms (Cheyenne, Casper, etc).
It would be good to have machine dependent configuration eventually in the jedi-stack build system.
