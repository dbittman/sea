VERSION=2.5.37
NAME=flex
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://downloads.sourceforge.net/project/flex/flex-2.5.37.tar.gz)
SOURCES_HASHES=(6c16fa35ba422bf809effa106d022a39)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --prefix=/usr --host=$HOST_TRIPLET M4=/usr/bin/m4; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install M4=usr/bin/m4; then
		return 1
	fi
}

