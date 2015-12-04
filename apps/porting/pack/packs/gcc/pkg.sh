VERSION=5.2.0
NAME=gcc
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/gcc/gcc-5.2.0/gcc-5.2.0.tar.bz2)
SOURCES_HASHES=(a51bcfeb3da7dd4c623e27207ed43467)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.bz2
	fi
}

function build() {
	SYSROOT=$($HOST_TRIPLET-gcc -print-sysroot)
	
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --target=$HOST_TRIPLET --enable-lto --disable-nls --enable-languages=c,c++ --with-build-sysroot=$SYSROOT; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

