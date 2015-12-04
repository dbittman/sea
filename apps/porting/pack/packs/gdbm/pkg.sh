VERSION=1.11
NAME=gdbm
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(ftp://ftp.gnu.org/gnu/gdbm/gdbm-1.11.tar.gz)
SOURCES_HASHES=(72c832680cf0999caedbe5b265c8c1bd)
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

