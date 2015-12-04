VERSION=1.42.13
NAME=e2fsprogs
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.42.13/e2fsprogs-1.42.13.tar.xz)
SOURCES_HASHES=(ce8e4821f5f53d4ebff4195038e38673)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.xz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET --disable-nls --disable-uuidd; then
		return 1
	fi

	if ! make RDYNAMIC= DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

