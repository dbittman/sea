P_NAME = 0
P_VERSION = 1
P_URL = 2
P_CONFIG_F = 3
P_MAKE_F = 4
P_PREFIX = 5
P_TARGETS = 6
P_HOSTORTARG = 7
P_CONFIGSUB = 8
P_COMMENT = 9

# [ NAME  ,  VERSION  ,  URL  ,  configure FLAGS  ,  make FLAGS  ,  INSTALL PREFIX  ,  TARGETS  ,  --{??}=$target  ,  CONFIG.SUB LOCATION  ,  COMMENTS ]
$grep_dat  = ["grep", "2.12", "http://ftp.gnu.org/gnu/grep/grep-2.12.tar.xz", "", "", "/usr", "all install", "host", "", ""]

$autoconf  = ["autoconf", "2.69", "http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz", "", "", "/usr", "all install", "host", "", ""]
$automake  = ["automake", "1.13", "http://ftp.gnu.org/gnu/automake/automake-1.13.tar.xz", "", "", "/usr", "all install", "host", "", ""]
$bash      = ["bash", "4.2", "http://ftp.gnu.org/gnu/bash/bash-4.2.tar.gz", "--build=$(sh ../bash-4.2/support/config.guess) --without-bash-malloc --without-curses --disable-job-control --datarootdir=/usr/share", "", "/", "all install", "host", "", ""]

$binutils  = ["binutils", "2.22", "http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz", "--disable-nls", "", "/usr", "all install", "host", "", ""]
$coreutils = ["coreutils", "8.16", "http://ftp.gnu.org/gnu/coreutils/coreutils-8.16.tar.xz", "--disable-nls --enable-no-install-program=hostname,su --datarootdir=/usr/share", "OPTIONAL_PKGLIB_PROGS=", "/", "all install", "host", "", ""]
$diffutils = ["diffutils", "3.2", "http://ftp.gnu.org/gnu/diffutils/diffutils-3.2.tar.gz", "", "", "/usr", "all install", "host", "", ""]

$e2fsprogs = ["e2fsprogs", "1.42.2", "http://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.42.2/e2fsprogs-1.42.2.tar.gz", "--disable-nls --disable-uuidd", "RDYNAMIC=", "/usr", "all install", "host", "", ""]
$findutils = ["findutils", "4.4.2", "http://ftp.gnu.org/gnu/findutils/findutils-4.4.2.tar.gz", "", "", "/usr", "all install", "host", "", ""]
$gawk      = ["gawk", "4.0.1", "http://ftp.gnu.org/gnu/gawk/gawk-4.0.1.tar.gz", "", "", "/usr", "all install", "host", "", ""]

$grub      = ["grub", "0.97", "ftp://alpha.gnu.org/gnu/grub/grub-0.97.tar.gz", "--without-curses", "", "/usr", "all install", "host", "", ""]
$less      = ["less", "443", "http://ftp.gnu.org/gnu/less/less-443.tar.gz", "", "", "/usr", "all install", "host", "", ""]
$make      = ["make", "3.82", "http://ftp.gnu.org/gnu/make/make-3.82.tar.gz", "", "", "/usr", "all install", "host", "", ""]

$nano      = ["nano", "2.3.1", "http://ftp.gnu.org/gnu/nano/nano-2.3.1.tar.gz", "", "", "/usr", "all install", "host", "", ""]
$nasm      = ["nasm", "2.10", "http://www.nasm.us/pub/nasm/releasebuilds/2.10/nasm-2.10.tar.gz", "", "", "/usr", "", "host", "", ""]
$ncurses   = ["ncurses", "5.9", "http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz", "--enable-termcap --disable-database --without-cxx --without-cxx-binding --oldincludedir=/usr/include --includedir=/usr/include", "", "/usr", "all install", "host", "", ""]

$patch     = ["patch", "2.6", "http://ftp.gnu.org/gnu/patch/patch-2.6.tar.gz", "", "", "/usr", "all install", "host", "", ""]
$sed       = ["sed", "4.2", "http://ftp.gnu.org/gnu/sed/sed-4.2.tar.gz", "", "", "/usr", "all install", "host", "", ""]
$tar       = ["tar", "1.26", "http://ftp.gnu.org/gnu/tar/tar-1.26.tar.gz", "", "", "/usr", "all install", "host", "", ""]

$termcap   = ["termcap", "1.3.1", "http://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz", "", "CC=#{$target}-gcc AR=#{$target}-ar RANLIB=#{$target}-ranlib", "/usr", "", "host", "", ""]
$readline  = ["readline", "6.2", "http://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz", "--without-curses --enable-shared=no", "SHOBJ_LDFLAGS=-ltermcap SHOBJ_CFLAGS=", "/usr", "all install", "host", "", "*** DISREGARD THESE ERRORS ***"]

$which     = ["which", "2.20", "http://ftp.gnu.org/gnu/which/which-2.20.tar.gz", "", "", "/usr", "all install", "host", "", ""]
$fortune   = ["fortune", "001", "", "", "", "/usr", "", "", "", ""]
$seaosutil = ["seaosutil", "1.0", "", "", "", "/", "all install", "host", "", ""]

$newlib    = ["newlib", "2.0.0", "", "--exec-prefix=/usr --libdir=/usr/lib --includedir=/usr/include", "", "/usr", "all install", "target", "", ""]
$gcc       = ["gcc", "4.7.3", "http://ftp.gnu.org/gnu/gcc/gcc-4.7.3/gcc-4.7.3.tar.gz", "--enable-lto --disable-nls --enable-languages=c,c++ CC_FOR_TARGET=#{$target}-gcc AR_FOR_TARGET=#{$target}-ar AS_FOR_TARGET=#{$target}-as RANLIB_FOR_TARGET=#{$target}-ranlib STRIP_FOR_TARGET=#{$target}-strip", "CC_FOR_TARGET=#{$target}-gcc AR_FOR_TARGET=#{$target}-ar AS_FOR_TARGET=#{$target}-as RANLIB_FOR_TARGET=#{$target}-ranlib STRIP_FOR_TARGET=#{$target}-strip", "/usr", "all-gcc install-gcc all-target-libgcc install-target-libgcc", "host", "", ""]
$gzip      = ["gzip", "1.4", "http://ftp.gnu.org/gnu/gzip/gzip-1.4.tar.gz", "", "", "/usr", "all install", "host", "", ""]

$packages.insert(-1, $grep_dat)
$packages.insert(-1, $bash)
$packages.insert(-1, $autoconf)
$packages.insert(-1, $automake)
$packages.insert(-1, $binutils)
$packages.insert(-1, $coreutils)
$packages.insert(-1, $diffutils)
$packages.insert(-1, $e2fsprogs)
$packages.insert(-1, $findutils)
$packages.insert(-1, $gawk)
$packages.insert(-1, $grub)
$packages.insert(-1, $less)
$packages.insert(-1, $make)
$packages.insert(-1, $nano)
$packages.insert(-1, $nasm)
$packages.insert(-1, $ncurses)
$packages.insert(-1, $patch)
$packages.insert(-1, $sed)
$packages.insert(-1, $tar)
$packages.insert(-1, $which)
$packages.insert(-1, $fortune)
$packages.insert(-1, $seaosutil)
$packages.insert(-1, $newlib)
$packages.insert(-1, $gcc)
$packages.insert(-1, $readline)
$packages.insert(-1, $termcap)
$packages.insert(-1, $gzip)
