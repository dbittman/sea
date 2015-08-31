VERSION=1.14
NAME=automake
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.xz)
SOURCES_HASHES=(cb3fba6d631cddf12e230fd0cc1890df)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.xz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET; then
		return 1
	fi

	if ! DESTDIR=$INSTALL_ROOT make -j$INDIV_PARALLEL all install; then
		return 1
	fi
}

