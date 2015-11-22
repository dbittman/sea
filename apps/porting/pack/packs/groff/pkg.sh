VERSION=1.22.3
NAME=groff
DESC=
DEPENDS=
CONFLICTS=

SOURCES=(http://ftp.gnu.org/gnu/groff/groff-1.22.3.tar.gz)
SOURCES_HASHES=(cc825fa64bc7306a885f2fb2268d3ec5)
PATCHES=("patches/$NAME-$VERSION-seaos-all.patch")

function prepare() {
	if ! [ -d $NAME-$VERSION ]; then
		tar xf $NAME-$VERSION.tar.gz
	fi
}

function build() {
	if ! ../src/$NAME-$VERSION/configure --sysconfdir=/etc --prefix=/usr --host=$HOST_TRIPLET --build=$(sh ../src/groff-1.22.3/config.guess); then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT -j1 TROFFBIN=troff GROFFBIN=groff GROFF_BIN_PATH= all install; then
		return 1
	fi
}

