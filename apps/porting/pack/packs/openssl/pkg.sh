VERSION=1.0.1f
NAME=openssl
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://www.openssl.org/source/openssl-1.0.1f.tar.gz)
SOURCES_HASHES=(f26b09c028a0541cab33da697d522b25)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	cp -r ../src/$NAME-$VERSION/* .
	if ! ./Configure --prefix=/usr --openssldir=/usr no-shared $HOST_TRIPLET; then
		return 1
	fi

	if ! make INSTALL_PREFIX=$INSTALL_ROOT -j1 build_libs install_sw; then
		return 1
	fi
}

