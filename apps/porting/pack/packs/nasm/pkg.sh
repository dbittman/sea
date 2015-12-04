VERSION=2.10
NAME=nasm
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://www.nasm.us/pub/nasm/releasebuilds/2.10/nasm-2.10.tar.gz)
SOURCES_HASHES=(f489359ddb90ec672937da4dbc0f02f1)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET; then
		return 1
	fi

	if ! make INSTALLROOT=$INSTALL_ROOT -j$INDIV_PARALLEL CFLAGS="-I. -I../" all install; then
		return 1
	fi
}

