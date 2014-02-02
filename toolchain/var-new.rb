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
$downloads_table = [
  ["binutils", "2.22" , true , "http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz" , "8b3ad7090e3989810943aa19103fdb83", []                                 , "target prefix                    ", "--disable-nls --disable-werror"                                         , ""            , "MAKEINFO=makeinfo all install"          , nil                                                            ],
  ["gcc"     , "4.8.0", true , "http://ftp.gnu.org/gnu/gcc/gcc-4.8.0/gcc-4.8.0.tar.gz", "f1011d59961a43d3d7c22913815812b3", ["binutils *"]                     , "target prefix                    ", "--enable-languages=c,c++ --enable-lto --disable-nls"                    , ""            , " all-gcc install-gcc"                   , nil                                                            ],
  ["newlib"  , "2.0.0", true , "ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz"  , "e3e936235e56d6a28afb2a7f98b1a635", ["binutils *", "gcc *"]            , "target prefix                    ", ""                                                                       , ""            , "all install"                            , nil                                                            ],
  ["libgcc"  , nil    , true , "gcc-4.8.0"                                            , nil                               , ["binutils *", "gcc *", "newlib *"], "target prefix                    ", nil                                                                      , ""            , "all-target-libgcc install-target-libgcc", nil                                                            ],
  ["termcap" , "1.3.1", false, "ftp://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz"   , "ffe6f86e63a3a29fa53ac645faaabdfa", ["binutils *", "gcc *", "newlib *"], "host tarprefix                   ", ""                                                                       , "CC AR RANLIB", "all install"                            , nil                                                            ],
  ["ncurses" , "5.9"  , false, "ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz"     , "8cb9c412e5f2d96bc6f459aa8c6282a1", ["binutils *", "gcc *", "newlib *"], "host tarprefix include oldinclude", "--enable-termcap --disable-database --without-cxx --without-cxx-binding", ""            , "all install"                            , "cp config.sub ncurses-5.9/config.sub"                         ],  
  ["readline", "6.2"  , false, "ftp://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz"   , "67948acb2ca081f23359d0256e9a271c", ["binutils *", "gcc *", "newlib *"], "host tarprefix                   ", "--without-curses --disable-shared"                                      , ""            , "all install"                            , "cp config.sub readline-6.2/support/config.sub"                ],
  ["gmp"     , "5.1.1", false, "ftp://ftp.gnu.org/gnu/gmp/gmp-5.1.1.tar.bz2"          , "2fa018a7cd193c78494525f236d02dd6", ["binutils *", "gcc *", "newlib *"], "host tarprefix                   ", ""                                                                       , ""            , "all install"                            , "cp config.sub gmp-5.1.1/configfsf.sub"                        ],
  ["mpfr"    , "3.1.2", false, "ftp://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.gz"         , "181aa7bb0e452c409f2788a4a7f38476", ["binutils *", "gcc *", "newlib *"], "host tarprefix                   ", "CFLAGS='-fno-stack-protector'"                                          , ""            , "all install"                            , "cp config.sub mpfr-3.1.2/config.sub"                          ],
  ["mpc"     , "1.0.1", false, "ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.1.tar.gz"           , "b32a2e1a3daa392372fbd586d1ed3679", ["binutils *", "gcc *", "newlib *"], "host tarprefix                   ", ""                                                                       , "CC AR LD"    , "all install"                            , "cp config.sub mpc-1.0.1/config.sub"                           ],
]
#   ["automake", "1.12.6", "ftp://ftp.gnu.org/gnu/automake/automake-1.12.6.tar.xz", "140e084223bf463a24c1a28427c6aec7", []],
# change this... maybe -j3 or so?
$make_flags = ""

# increment this when anything within the extra libraries changes
$extra_ver = "0001"
