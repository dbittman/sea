VERSION=2.0.0
NAME=newlib
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(ftp://sourceware.org/pub/newlib/newlib-2.0.0.tar.gz)
SOURCES_HASHES=(e3e936235e56d6a28afb2a7f98b1a635)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --target=$HOST_TRIPLET --exec-prefix=/usr --libdir=/usr/lib --includedir=/usr/include; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

