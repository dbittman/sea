VERSION=0.1
NAME=cond
DESC=
DEPENDS=
CONFLICTS=

SOURCES=()
SOURCES_HASHES=()
PATCHES=()

function prepare() {
	if ! [ -d $NAME ]; then
		cp -rf ../../../../../cond $NAME
	fi
}

function build() {
	if ! ../src/$NAME/configure --prefix=/ --host=$HOST_TRIPLET; then
		return 1
	fi

	if ! make DESTDIR=$INSTALL_ROOT all install; then
		return 1
	fi
}

