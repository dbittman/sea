VERSION=1.3.1
NAME=termcap
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.gz)
SOURCES_HASHES=(ffe6f86e63a3a29fa53ac645faaabdfa)
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

	if ! make DESTDIR=$INSTALL_ROOT -j$INDIV_PARALLEL CC=$HOST_TRIPLET-gcc AR=$HOST_TRIPLET-ar RANLIB=$HOST_TRIPLET-ranlib all install; then
		return 1
	fi
}

