VERSION=4.3
NAME=bash
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/$NAME/$NAME-${VERSION}.tar.gz)
SOURCES_HASHES=(81348932d5da294953e15d4814c74dd1)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/ --host=$HOST_TRIPLET --datarootdir=/usr/share --enable-history --build=$(sh ../src/bash-4.3/support/config.guess); then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -j$INDIV_PARALLEL all install; then
		return 1
	fi
}

