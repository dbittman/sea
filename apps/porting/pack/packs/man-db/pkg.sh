VERSION=2.7.5
NAME=man-db
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://download.savannah.gnu.org/releases/man-db/man-db-2.7.5.tar.xz)
SOURCES_HASHES=(37da0bb0400cc7b640f33c26f6052202)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.xz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --sysconfdir=/etc --prefix=/usr --host=$HOST_TRIPLET --build=$(sh ../src/bash-4.3/support/config.guess); then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -j1 all install; then
		return 1
	fi
}

