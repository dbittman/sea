VERSION=1.0.6
NAME=bzip2
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz)
SOURCES_HASHES=(00b516f4704d4a7cb50a1d97e6e8e15b)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	cp -rf ../src/bzip2-1.0.6/* .
	if ! make PREFIX=$INSTALL_ROOT CC=$HOST_TRIPLET-gcc RANLIB=$HOST_TRIPLET-ranlib AR=$HOST_TRIPLET-ar all install; then
		return 1
	fi
}

