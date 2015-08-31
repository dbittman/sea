VERSION=4.0.1
NAME=gawk
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.gz)
SOURCES_HASHES=(bab2bda483e9f32be65b43b8dab39fa5)
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

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

