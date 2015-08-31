VERSION=3.0
NAME=bison
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.xz)
SOURCES_HASHES=(a2624994561aa69f056c904c1ccb2880)
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

	if ! make DESTDIR=$INSTALL_ROOT -j$INDIV_PARALLEL all install; then
		return 1
	fi
}

