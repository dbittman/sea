VERSION=1.0.3
NAME=mpc
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz)
SOURCES_HASHES=(d6a1d5f8ddea3abd2cc3e98f58352d26)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --build=$(sh ../src/mpc-1.0.3/config.guess) --disable-shared --enable-static --with-sysroot=$($HOST_TRIPLET-gcc -print-sysroot) --with-gmp=$($HOST_TRIPLET-gcc -print-sysroot)/usr CC=$HOST_TRIPLET-gcc AR=$HOST_TRIPLET-ar LD=$HOST_TRIPLET-ld CFLAGS="" LDFLAGS="-L$($HOST_TRIPLET-gcc -print-sysroot)/usr/lib" LT_SYS_LIBRARY_PATH=$($HOST_TRIPLET-gcc -print-sysroot)/usr/lib; then
		return 1
	fi

	sed -i "s|sys_lib_dlsearch_path_spec=\"\/lib \/usr\/lib\"|sys_lib_dlsearch_path_spec=\"$($HOST_TRIPLET-gcc -print-sysroot)\/usr\/lib\"|g" libtool

	if ! make DESTDIR=$INSTALL_ROOT CC=$HOST_TRIPLET-gcc AR=$HOST_TRIPLET-ar LD=$HOST_TRIPLET-ld CFLAGS="" -j1 all install; then
		return 1
	fi
}

