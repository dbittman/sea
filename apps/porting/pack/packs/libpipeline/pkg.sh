VERSION=1.4.1
NAME=libpipeline
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.4.1.tar.gz)
SOURCES_HASHES=(e54590ec68d6c1239f67b5b44e92022c)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --build=$(sh ../src/bash-4.3/support/config.guess); then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -j1 all install; then
		return 1
	fi
}

