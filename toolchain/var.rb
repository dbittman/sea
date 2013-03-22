# pick your versions here. Note that there may not be patches
# available for every version...
$binutils_ver = "2.22"
$gcc_ver      = "4.7.1"
$newlib_ver   = "2.0.0"

# these shouldn't need to be edited...
$gcc_download = "http://ftp.gnu.org/gnu/gcc/gcc-#{$gcc_ver}/gcc-#{$gcc_ver}.tar.gz"
$binutils_download = "http://ftp.gnu.org/gnu/binutils/binutils-#{$binutils_ver}.tar.gz"
$newlib_download = "ftp://sourceware.org/pub/newlib/newlib-#{$newlib_ver}.tar.gz"

# below are default settings for various build system requirements.
# these work on my system, after installing the appropriate packages

# these are required by newlib
# path to automake version 1.12
$automake = "automake-1.12"
# path to aclocal version 1.12
$aclocal = "aclocal-1.12"

# and this is required by gcc :(
# ...version 2.64 of autoconf, that is
$autoconf = "/opt/autoconf/2.64/bin/autoconf"

# change this... maybe -j3 or so?
$make_flags = ""
