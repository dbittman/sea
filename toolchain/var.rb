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


$downloads_table = [
  ["binutils", 
      "2.22", 
      true, 
      "http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz", 
      "8b3ad7090e3989810943aa19103fdb83", 
      [],
      "target prefix", 
      "--disable-nls --disable-werror", 
      "", 
      "MAKEINFO=makeinfo all install", 
      nil
  ],
	
  ["gcc", 
      "4.9.0", 
      true, 
      "http://ftp.gnu.org/gnu/gcc/gcc-4.9.0/gcc-4.9.0.tar.bz2", 
      "9709b49ae0e904cbb0a6a1b62853b556", 
      ["binutils *"], 
      "target prefix", 
      "--enable-languages=c,c++ --enable-lto --disable-nls", 
      "", 
      "all-gcc install-gcc", 
      nil                                                            
  ],
	
  ["newlib", 
      "2.0.0", 
      true, 
      "ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz", 
      "e3e936235e56d6a28afb2a7f98b1a635", 
      ["binutils *", "gcc *"], 
      "target prefix", 
      "", 
      "", 
      "all install", 
      nil                                                            
  ],
	
  ["libgcc", 
      nil, 
      true, 
      "gcc-4.9.0", 
      nil, 
      ["binutils *", "gcc *", "newlib *"], 
      "target prefix", 
      nil, 
      "", 
      "all-target-libgcc install-target-libgcc",
      nil                                                            
  ],
	
  ["libstdc++", 
      nil, 
      true, 
      "gcc-4.9.0", 
      nil, 
      ["binutils *", "gcc *", "newlib *", "libgcc *"], 
      "target prefix",
      nil, 
      "", 
      "all install",
      nil                                                            
  ],
	
  ["termcap", 
      "1.3.1", 
      false, 
      "ftp://ftp.gnu.org/gnu/termcap/termcap-1.3.1.tar.gz", 
      "ffe6f86e63a3a29fa53ac645faaabdfa", 
      ["binutils *", "gcc *", "newlib *", "libgcc *"], 
      "host tarprefix", 
      "", 
      "CC AR RANLIB", 
      "all install",
      nil                                                            
  ],
	
  ["ncurses", 
      "5.9", 
      false, 
      "ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz", 
      "8cb9c412e5f2d96bc6f459aa8c6282a1", 
      ["binutils *", "gcc *", "newlib *", "termcap *", "libgcc *"], 
      "host tarprefix include oldinclude", 
      "--enable-termcap --disable-database", 
      "", 
      "all install", 
      "cp ../config.sub ncurses-5.9/config.sub"                         
  ],  
	
  ["readline", 
      "6.2", 
      false, 
      "ftp://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz", 
      "67948acb2ca081f23359d0256e9a271c", 
      ["binutils *", "gcc *", "newlib *", "termcap *", "libgcc *"],
      "host tarprefix", 
      "--without-curses --disable-shared", 
      "", 
      "all install", 
      "cp ../config.sub readline-6.2/support/config.sub"                
  ],
	
  ["gmp", 
      "5.1.1", 
      false, 
      "ftp://ftp.gnu.org/gnu/gmp/gmp-5.1.1.tar.bz2", 
      "2fa018a7cd193c78494525f236d02dd6", 
      ["binutils *", "gcc *", "newlib *", "libgcc *"], 
      "host tarprefix", 
      "", 
      "", 
      "all install", 
      "cp ../config.sub gmp-5.1.1/configfsf.sub"                        
  ],
	
  ["mpfr", 
      "3.1.2", 
      false, 
      "ftp://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.gz", 
      "181aa7bb0e452c409f2788a4a7f38476", 
      ["binutils *", "gcc *", "newlib *", "libgcc *"], 
      "host tarprefix", 
      "CFLAGS='-fno-stack-protector'", 
      "", 
      "all install", 
      "cp ../config.sub mpfr-3.1.2/config.sub"                          
  ],
	
  ["mpc", 
      "1.0.1", 
      false, 
      "ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.1.tar.gz", 
      "b32a2e1a3daa392372fbd586d1ed3679", 
      ["binutils *", "gcc *", "newlib *", "libgcc *"], 
      "host tarprefix", 
      "", 
      "CC AR LD", 
      "all install", 
      "cp ../config.sub mpc-1.0.1/config.sub"                           
  ],
  ["openssl", 
      "1.0.1f", 
      true, 
      "http://www.openssl.org/source/openssl-1.0.1f.tar.gz", 
      "f26b09c028a0541cab33da697d522b25", 
      ["binutils *", "gcc *", "newlib *", "libgcc *"], 
      "puretarget tarprefix openssldir", 
      "no-shared", 
      "", 
      "build_libs install_sw", 
      "chmod a+x openssl-1.0.1f/configure"                         
  ],
]

# Global make flags - applied to every build process
$make_flags = ""

# increment this when anything within the extra libraries changes
$extra_ver = "0001"
