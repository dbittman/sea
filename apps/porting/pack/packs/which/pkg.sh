VERSION=2.20
NAME=which
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.gz)
SOURCES_HASHES=(95be0501a466e515422cde4af46b2744)
PATCHES=()

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

