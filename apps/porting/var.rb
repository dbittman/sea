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

# bash nasm
# ncurses: --without-cxx
# newlib install dir...
# termcap

$downloads_table = [
  ["autoconf",
     "2.69",
     true,
     "http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz",
     "50f97f4159805e374639a73e2636f22e",
     [],
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["automake",
     "1.13",
     true,
     "http://ftp.gnu.org/gnu/automake/automake-1.13.tar.xz",
     "bb37ffad523a1928efdd157b6561b631",
     [],
     "host",
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
      "host",
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
     "host",
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
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["e2fsprogs",
     "1.42.2",
     true,
     "http://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.42.2/e2fsprogs-1.42.2.tar.gz",
     "04f4561a54ad0419248316a00c016baa",
     [],
     "host",
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
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["gawk",
     "4.0.1",
     true,
     "http://ftp.gnu.org/gnu/gawk/gawk-4.0.1.tar.gz",
     "bab2bda483e9f32be65b43b8dab39fa5",
     [],
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["grub",
     "0.97",
     true,
     "ftp://alpha.gnu.org/gnu/grub/grub-0.97.tar.gz",
     "cd3f3eb54446be6003156158d51f4884",
     [],
     "host",
     "--prefix=/usr --without-curses",
     "DESTDIR",
     "all install",
     nil
  ],

  ["less",
     "443",
     true,
     "http://ftp.gnu.org/gnu/less/less-443.tar.gz",
     "47db098fb3cdaf847b3c4be05ee954fc",
     [],
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["make",
     "3.82",
     true,
     "http://ftp.gnu.org/gnu/make/make-3.82.tar.gz",
     "7f7c000e3b30c6840f2e9cf86b254fac",
     [],
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["nano",
     "2.3.1",
     true,
     "http://ftp.gnu.org/gnu/nano/nano-2.3.1.tar.gz",
     "af09f8828744b0ea0808d6c19a2b4bfd",
     [],
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["ncurses",
     "5.9",
     true,
     "http://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz",
     "8cb9c412e5f2d96bc6f459aa8c6282a1",
     [],
     "host",
     "--prefix=/usr --enable-termcap --disable-database --without-cxx --without-cxx-binding --oldincludedir=/usr/include --includedir=/usr/include",
     "DESTDIR",
     "all install",
     nil
  ],

  ["patch",
     "2.6",
     true,
     "http://ftp.gnu.org/gnu/patch/patch-2.6.tar.gz",
     "bc71d33c35004db3768465bcaf9ed23c",
     [],
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],

  ["sed",
     "4.2",
     true,
     "http://ftp.gnu.org/gnu/sed/sed-4.2.tar.gz",
     "31580bee0c109c0fc8f31c4cf204757e",
     [],
     "host",
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
     "host",
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
     "host",
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
     "target",
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
     "host",
     "--prefix=/usr",
     "DESTDIR",
     "all install",
     nil
  ],
	
  ["gcc",
     "4.8.0",
     true,
     "http://ftp.gnu.org/gnu/gcc/gcc-4.8.0/gcc-4.8.0.tar.gz",
     "f1011d59961a43d3d7c22913815812b3",
     [],
     "host cc_for_target ar_for_target as_for_target ranlib_for_target strip_for_target",
     "--prefix=/usr --enable-lto --disable-nls --enable-languages=c,c++",
     "DESTDIR CC AR cc_for_target ar_for_target as_for_target ranlib_for_target strip_for_target",
     "all install",
     nil
  ],
	
  ["binutils",
     "2.22", 
     true, 
     "http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz", 
     "8b3ad7090e3989810943aa19103fdb83", 
     [],
     "host",
     "--prefix=/usr --disable-nls",
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
     "host",
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
     "host",
     "--prefix=/usr --without-curses --enable-shared=no",
     "DESTDIR",
     "SHOBJ_LDFLAGS=-ltermcap SHOBJ_CFLAGS= all install",
     nil
  ],

]

# Global make flags - applied to every build process
$make_flags = ""
