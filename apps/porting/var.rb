DT_NAME    = 0
DT_VERSION = 1
DT_PATCH   = 2
DT_REMOTE  = 3
DT_HASH    = 4
DT_DEPS    = 5
DT_CROSS   = 6
DT_CONFIG  = 7
DT_MCROSS  = 8
DT_MAKE    = 9
DT_COMMAND = 10

# Each entry contains (in order):
# Package Name
# * Package Version
# * Whether or not a patch is needed for this program
# * The link to the remote download location
# * Hash of the archive
# * Dependencies of the package
# * Dynamic configure options: Options for the configure script that cannot be statically determined
#   i.e., they are based on $target and $install. The following are supported:
#    - target: Adds '--target=#{$target}'
#    - prefix: Adds '--prefix=#{$install}'
#    - tarprefix: Adds '--prefix=#{$install}/#{$target}'
#    - host: Adds '--host=#{$target}'
#   any number of these may be specified, space seperated, in a single string
# * Static configure options
# * Dynamic make options: Same as for configure options, these are usually used to specify variables
#   like CC and LD. The following are supported:
#    - CC: Adds 'CC=#{$target}-gcc'
#    - RANLIB: Adds 'RANLIB=#{$target}-ranlib'
#    - AR: Adds 'AR=#{$target}-at'
#    - LD: Adds 'LD=#{$target}-ld'
# * Static make options & make targets
# * Special command to run before running configure or make (used to copy in corrected config.sub file)

# If the version entry is set to nil, then it assumes the package is part of another package, and doesn't
# download, extract, patch or configure the package, it just builds it (used for libgcc)

#   ["grep",
#      "2.12",
#      true,
#      "http://ftp.gnu.org/gnu/grep/grep-2.12.tar.xz",
#      "8d2f0346d08b13c18afb81f0e8aa1e2f",
#      [],
#      "host",
#      "--prefix=/usr",
#      "DESTDIR",
#      "all install",
#      nil
#   ],

# ncurses: --without-cxx
# newlib install dir...
# port the remaining things (seaosutils, etc)
# merge this build.rb system with the toolchain one

$downloads_table = [
  ["autoconf",
     "2.69",
     true,
     "http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz",
     "50f97f4159805e374639a73e2636f22e",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["automake",
     "1.14",
     true,
     "http://ftp.gnu.org/gnu/automake/automake-1.14.tar.xz",
     "cb3fba6d631cddf12e230fd0cc1890df",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["bash",
     "4.3",
     true,
     "http://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz",
     "81348932d5da294953e15d4814c74dd1",
     [],
     "build host",
     "--prefix=/ --build=$(sh ../bash-4.3/support/config.guess) --datarootdir=/usr/share --enable-history",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["bison",
     "3.0",
     true,
     "http://ftp.gnu.org/gnu/bison/bison-3.0.tar.xz",
     "a2624994561aa69f056c904c1ccb2880",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["coreutils",
      "8.16",
      true,
      "http://ftp.gnu.org/gnu/coreutils/coreutils-8.16.tar.xz",
      "89b06f91634208dceba7b36ad1f9e8b9",
      [],
      "build host",
      "--disable-nls --enable-no-install-program=hostname,su --datarootdir=/usr/share --prefix=/",
      "DESTDIR",
      "OPTIONAL_PKGLIB_PROGS= all install",
      nil,
  ],
	
  ["diffutils",
     "3.2",
     true,
     "http://ftp.gnu.org/gnu/diffutils/diffutils-3.2.tar.gz",
     "22e4deef5d8949a727b159d6bc65c1cc",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["grep",
     "2.12",
     true,
     "http://ftp.gnu.org/gnu/grep/grep-2.12.tar.xz",
     "8d2f0346d08b13c18afb81f0e8aa1e2f",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["e2fsprogs",
     "1.42.13",
     true,
     "https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.42.13/e2fsprogs-1.42.13.tar.xz",
     "ce8e4821f5f53d4ebff4195038e38673",
     [],
     "build host",
     "--prefix=/usr --disable-nls --disable-uuidd",
     "DESTDIR",
     "RDYNAMIC= all install",
     nil
  ],

  ["findutils",
     "4.4.2",
     true,
     "http://ftp.gnu.org/gnu/findutils/findutils-4.4.2.tar.gz",
     "351cc4adb07d54877fa15f75fb77d39f",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["flex",
     "2.5.37",
     true,
     "http://downloads.sourceforge.net/project/flex/flex-2.5.37.tar.gz",
     "6c16fa35ba422bf809effa106d022a39",
     [],
     "build host",
     "--prefix=/usr M4=/usr/bin/m4",
     "DESTDIR",
     "all install M4=/usr/bin/m4",
     nil
  ],

  ["gawk",
     "4.0.1",
     true,
     "http://ftp.gnu.org/gnu/gawk/gawk-4.0.1.tar.gz",
     "bab2bda483e9f32be65b43b8dab39fa5",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["grub-legacy",
     "0.97",
     true,
     "ftp://alpha.gnu.org/gnu/grub/grub-0.97.tar.gz",
     "cd3f3eb54446be6003156158d51f4884",
     [],
     "build host",
     "--prefix=/usr --without-curses",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["grub",
     "2.00",
     true,
     "ftp://ftp.gnu.org/gnu/grub/grub-2.00.tar.xz",
     "a1043102fbc7bcedbf53e7ee3d17ab91",
     [],
     "build host",
     "--prefix=/usr --disable-werror --disable-grub-mkfont",
     "DESTDIR",
     "all install",
     nil
  ],

  ["less",
     "443",
     false,
     "http://ftp.gnu.org/gnu/less/less-443.tar.gz",
     "47db098fb3cdaf847b3c4be05ee954fc",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["m4",
     "1.4.17",
     true,
     "ftp://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.xz",
     "12a3c829301a4fd6586a57d3fcf196dc",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["make",
     "4.0",
     true,
     "http://ftp.gnu.org/gnu/make/make-4.0.tar.bz2",
     "571d470a7647b455e3af3f92d79f1c18",
     [],
     "build host",
     "--prefix=/usr --without-guile --disable-load",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["nano",
     "2.4.2",
     true,
     "http://www.nano-editor.org/dist/v2.4/nano-2.4.2.tar.gz",
     "ce6968992fec4283c17984b53554168b",
     [],
     "build host",
     "--prefix=/usr --enable-utf8=no CURSES_LIB_NAME=ncurses",
     "DESTDIR",
     "all install LIBS=-lncurses",
     nil
  ],

  ["nasm",
     "2.10",
     true,
     "http://www.nasm.us/pub/nasm/releasebuilds/2.10/nasm-2.10.tar.gz",
     "f489359ddb90ec672937da4dbc0f02f1",
     [],
     "build host",
     "--prefix=/usr",
     "INSTALLROOT",
     "CFLAGS=\"-I. -I../\" all install",
     nil
  ],
	
  ["ncurses",
     "6.0",
     true,
     "http://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz",
     "ee13d052e1ead260d7c28071f46eefb1",
     [],
     "build host",
     "--prefix=/usr --enable-termcap --disable-database --oldincludedir=/usr/include --includedir=/usr/include",
     "DESTDIR",
     "all install -i",
     nil
  ],

  ["patch",
     "2.6",
     true,
     "http://ftp.gnu.org/gnu/patch/patch-2.6.tar.gz",
     "bc71d33c35004db3768465bcaf9ed23c",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["seaosutil",
     "0.2",
     false,
     nil,
     "",
     [],
     "build host",
     "--prefix=/",
     "DESTDIR",
     "all install",
     "cp -rf ../../seaos-util seaosutil-0.2"
  ],
	
  ["sed",
     "4.2",
     true,
     "http://ftp.gnu.org/gnu/sed/sed-4.2.tar.gz",
     "31580bee0c109c0fc8f31c4cf204757e",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["tar",
     "1.26",
     true,
     "http://ftp.gnu.org/gnu/tar/tar-1.26.tar.gz",
     "00d1e769c6af702c542cca54b728920d",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["which",
     "2.20",
     false,
     "http://ftp.gnu.org/gnu/which/which-2.20.tar.gz",
     "95be0501a466e515422cde4af46b2744",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["newlib",
     "2.0.0",
     true,
     "ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz", 
     "e3e936235e56d6a28afb2a7f98b1a635", 
     [],
     "build target",
     "--prefix=/usr --exec-prefix=/usr --libdir=/usr/lib --includedir=/usr/include",
     "DESTDIR",
     "all install",
     nil
  ],

  ["gzip",
     "1.4",
     true,
     "http://ftp.gnu.org/gnu/gzip/gzip-1.4.tar.gz",
     "e381b8506210c794278f5527cba0e765",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["gcc",
     "5.2.0",
     true,
     "http://ftp.gnu.org/gnu/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2",
     "a51bcfeb3da7dd4c623e27207ed43467",
     [],
     "build host target cc_for_target ar_for_target as_for_target ranlib_for_target strip_for_target cxx_for_target",
     "--prefix=/usr --enable-lto --disable-nls --enable-languages=c,c++",
     "DESTDIR CC CXX AR cc_for_target ar_for_target as_for_target ranlib_for_target strip_for_target cxx_for_target",
     "all install",
     nil
  ],
	
  ["binutils",
     "2.25.1", 
     true, 
     "http://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2", 
     "ac493a78de4fee895961d025b7905be4", 
     [],
     "build host",
     "--prefix=/usr --disable-nls --disable-werror",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["termcap",
     "1.3.1",
     true,
     "http://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz",
     "ffe6f86e63a3a29fa53ac645faaabdfa",
     [],
     "build host",
     "--prefix=/usr",
     "DESTDIR CC AR RANLIB",
     "all install",
     nil
  ],
	
  ["readline",
     "6.2",
     true,
     "http://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz",
     "67948acb2ca081f23359d0256e9a271c",
     [],
     "build host",
     "--prefix=/usr --without-curses --enable-shared=no",
     "DESTDIR",
     "SHOBJ_LDFLAGS=-ltermcap SHOBJ_CFLAGS= all install",
     nil
  ],
  ["openssl", 
      "1.0.1f", 
      true, 
      "http://www.openssl.org/source/openssl-1.0.1f.tar.gz", 
      "f26b09c028a0541cab33da697d522b25", 
      [], 
      "puretarget", 
      "no-shared --prefix=/usr --openssldir=/usr", 
      "INSTALL_PREFIX", 
      "build_libs install_sw", 
      "chmod a+x openssl-1.0.1f/configure"                         
  ],

]

# Global make flags - applied to every build process
$make_flags = ""
