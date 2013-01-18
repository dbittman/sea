/* ....... */
int rpmatch(char *i)
{
	if(!i) return -1;
	if(*(i) == 'y' || *(i) == 'Y')
		return 1;
	if((*(i) == 'o' || *i == 'O') && (*i=='k' || *i=='K'))
		return 1;
	return 0;
}

char *gai_strerror(int code)
{
	return "unknown error";
}

#define	_U	01
#define	_L	02
#define	_N	04
#define	_S	010
#define _P	020
#define _C	040
#define _X	0100
#define	_B	0200

#define _CTYPE_DATA_0_127 \
_C,	_C,	_C,	_C,	_C,	_C,	_C,	_C, \
_C,	_C|_S, _C|_S, _C|_S,	_C|_S,	_C|_S,	_C,	_C, \
_C,	_C,	_C,	_C,	_C,	_C,	_C,	_C, \
_C,	_C,	_C,	_C,	_C,	_C,	_C,	_C, \
_S|_B,	_P,	_P,	_P,	_P,	_P,	_P,	_P, \
_P,	_P,	_P,	_P,	_P,	_P,	_P,	_P, \
_N,	_N,	_N,	_N,	_N,	_N,	_N,	_N, \
_N,	_N,	_P,	_P,	_P,	_P,	_P,	_P, \
_P,	_U|_X,	_U|_X,	_U|_X,	_U|_X,	_U|_X,	_U|_X,	_U, \
_U,	_U,	_U,	_U,	_U,	_U,	_U,	_U, \
_U,	_U,	_U,	_U,	_U,	_U,	_U,	_U, \
_U,	_U,	_U,	_P,	_P,	_P,	_P,	_P, \
_P,	_L|_X,	_L|_X,	_L|_X,	_L|_X,	_L|_X,	_L|_X,	_L, \
_L,	_L,	_L,	_L,	_L,	_L,	_L,	_L, \
_L,	_L,	_L,	_L,	_L,	_L,	_L,	_L, \
_L,	_L,	_L,	_P,	_P,	_P,	_P,	_C

#define _CTYPE_DATA_128_255 \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0, \
0,	0,	0,	0,	0,	0,	0,	0

char _ctype_b[128 + 256] = {
	_CTYPE_DATA_128_255,
	_CTYPE_DATA_0_127,
	_CTYPE_DATA_128_255
};



char *__ctype_ptr = (char *)(_ctype_b+127);
//char *__ctype_ptr__ = (char *)(_ctype_b+127);
