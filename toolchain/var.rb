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

# extra libraries
$gmp_ver = "5.1.1"
$mpfr_ver = "3.1.2"
$mpc_ver = "1.0.1"
$ncurses_ver = "5.9"
$readline_ver = "6.2"
$termcap_ver = "1.3.1"

$gmp = "ftp://ftp.gnu.org/gnu/gmp/gmp-#{$gmp_ver}.tar.bz2"
$mpfr = "ftp://ftp.gnu.org/gnu/mpfr/mpfr-#{$mpfr_ver}.tar.gz"
$mpc = "ftp://ftp.gnu.org/gnu/mpc/mpc-#{$mpc_ver}.tar.gz"
$ncurses = "ftp://ftp.gnu.org/gnu/ncurses/ncurses-#{$ncurses_ver}.tar.gz"
$readline = "ftp://ftp.gnu.org/gnu/readline/readline-#{$readline_ver}.tar.gz"
$termcap = "ftp://ftp.gnu.org/gnu/termcap/termcap-#{$termcap_ver}.tar.gz" 

