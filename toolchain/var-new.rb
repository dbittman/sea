DT_NAME    = 0
DT_VERSION = 1
DT_REMOTE  = 2
DT_HASH    = 3
DT_DEPS    = 4

$downloads_table = [
  ["autoconf", "2.64", "ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.64.tar.xz", "9decdd5c672fd403ea467bb0789bc194", []],
  ["binutils", "2.22", "http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz", "8b3ad7090e3989810943aa19103fdb83", []],
  ["gcc", "4.8.0", "http://ftp.gnu.org/gnu/gcc/gcc-4.8.0/gcc-4.8.0.tar.gz", "f1011d59961a43d3d7c22913815812b3", ["binutils *", "autoconf 2.64"]],
  ["newlib", "2.0.0", "ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz", "e3e936235e56d6a28afb2a7f98b1a635", ["binutils *", "gcc *"]],
  ["gmp", "5.1.1", "ftp://ftp.gnu.org/gnu/gmp/gmp-5.1.1.tar.bz2", "2fa018a7cd193c78494525f236d02dd6", ["binutils *", "gcc *", "newlib *"]],
  ["mpfr", "3.1.2", "ftp://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.gz", "181aa7bb0e452c409f2788a4a7f38476", ["binutils *", "gcc *", "newlib *"]],
  ["mpc", "1.0.1", "ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.1.tar.gz", "b32a2e1a3daa392372fbd586d1ed3679", ["binutils *", "gcc *", "newlib *"]],
  ["ncurses", "5.9", "ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz", "8cb9c412e5f2d96bc6f459aa8c6282a1", ["binutils *", "gcc *", "newlib *"]],
  ["readline", "6.2", "ftp://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz", "67948acb2ca081f23359d0256e9a271c", ["binutils *", "gcc *", "newlib *"]],
  ["termcap", "1.3.1", "ftp://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz", "ffe6f86e63a3a29fa53ac645faaabdfa", ["binutils *", "gcc *", "newlib *"]]
]
#   ["automake", "1.12.6", "ftp://ftp.gnu.org/gnu/automake/automake-1.12.6.tar.xz", "140e084223bf463a24c1a28427c6aec7", []],
# change this... maybe -j3 or so?
$make_flags = ""

# increment this when anything within the extra libraries changes
$extra_ver = "0001"
