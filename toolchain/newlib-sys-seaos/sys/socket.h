#ifndef _SYS_SOCKET_H
#define _SYS_SOCKET_H
#include <sys/types.h>
#include <sys/_types.h>

typedef	unsigned int	sa_family_t;


typedef	unsigned	socklen_t;

struct sockaddr {
	sa_family_t	sa_family;	/* address family */
	char		sa_data[14];	/* actually longer; address value */
};

/*
 * Types
 */
#define	SOCK_STREAM	1		/* stream socket */
#define	SOCK_DGRAM	2		/* datagram socket */
#define	SOCK_RAW	3		/* raw-protocol interface */
#define	SOCK_RDM	4		/* reliably-delivered message */
#define	SOCK_SEQPACKET	5		/* sequenced packet stream */

/*
 * Option flags per-socket.
 */
#define	SO_DEBUG	0x0001		/* turn on debugging info recording */
#define	SO_ACCEPTCONN	0x0002		/* socket has had listen() */
#define	SO_REUSEADDR	0x0004		/* allow local address reuse */
#define	SO_KEEPALIVE	0x0008		/* keep connections alive */
#define	SO_DONTROUTE	0x0010		/* just use interface addresses */
#define	SO_BROADCAST	0x0020		/* permit sending of broadcast msgs */
#define	SO_USELOOPBACK	0x0040		/* bypass hardware when possible */
#define	SO_LINGER	0x0080		/* linger on close if data present */
#define	SO_OOBINLINE	0x0100		/* leave received OOB data in line */
#define	SO_REUSEPORT	0x0200		/* allow local address & port reuse */
#define	SO_TIMESTAMP	0x0400		/* timestamp received dgram traffic */
#define	SO_ACCEPTFILTER	0x1000		/* there is an accept filter */

/*
 * Additional options, not kept in so_options.
 */
#define SO_SNDBUF	0x1001		/* send buffer size */
#define SO_RCVBUF	0x1002		/* receive buffer size */
#define SO_SNDLOWAT	0x1003		/* send low-water mark */
#define SO_RCVLOWAT	0x1004		/* receive low-water mark */
#define SO_SNDTIMEO	0x1005		/* send timeout */
#define SO_RCVTIMEO	0x1006		/* receive timeout */
#define	SO_ERROR	0x1007		/* get error status and clear */
#define	SO_TYPE		0x1008		/* get socket type */
/*efine	SO_PRIVSTATE	0x1009		   get/deny privileged state */

/*
 * Structure used for manipulating linger option.
 */
struct linger {
	int	l_onoff;		/* option on/off */
	int	l_linger;		/* linger time */
};

struct accept_filter_arg {
	char	af_name[16];
	char	af_arg[256-16];
};

/*
 * Level number for (get/set)sockopt() to apply to socket itself.
 */
#define	SOL_SOCKET	0xffff		/* options for socket level */

/* Protocol families.  */
#define	PF_UNSPEC	0	/* Unspecified.  */
#define	PF_LOCAL	1	/* Local to host (pipes and file-domain).  */
#define	PF_UNIX		PF_LOCAL /* Old BSD name for PF_LOCAL.  */
#define	PF_FILE		PF_LOCAL /* Another non-standard name for PF_LOCAL.  */
#define	PF_MAX		32	/* For now..  */

/* Address families.  */
#define	AF_LOCAL	PF_LOCAL
#define	AF_UNIX		PF_UNIX
#define	AF_FILE		PF_FILE

/*
 * Structure used by kernel to pass protocol
 * information in raw sockets.
 */
struct sockproto {
	u_short	sp_family;		/* address family */
	u_short	sp_protocol;		/* protocol */
};

/*
 * RFC 2553: protocol-independent placeholder for socket addresses
 */
#define	_SS_MAXSIZE	128U
#define	_SS_ALIGNSIZE	(sizeof(long long))
#define	_SS_PAD1SIZE	(_SS_ALIGNSIZE - sizeof(unsigned char) - sizeof(sa_family_t))
#define	_SS_PAD2SIZE	(_SS_MAXSIZE - sizeof(unsigned char) - sizeof(sa_family_t) - \
_SS_PAD1SIZE - _SS_ALIGNSIZE)

struct sockaddr_storage {
	unsigned char		ss_len;		/* address length */
	sa_family_t	ss_family;	/* address family */
	char		__ss_pad1[_SS_PAD1SIZE];
	long long	__ss_align;	/* force desired structure storage alignment */
	char		__ss_pad2[_SS_PAD2SIZE];
};

/*
 * Definitions for network related sysctl, CTL_NET.
 *
 * Second level is protocol family.
 * Third level is protocol number.
 *
 * Further levels are defined by the individual families below.
 */
#define NET_MAXID	AF_MAX

#define CTL_NET_NAMES { \
{ 0, 0 }, \
{ "unix", CTLTYPE_NODE }, \
{ "inet", CTLTYPE_NODE }, \
{ "implink", CTLTYPE_NODE }, \
{ "pup", CTLTYPE_NODE }, \
{ "chaos", CTLTYPE_NODE }, \
{ "xerox_ns", CTLTYPE_NODE }, \
{ "iso", CTLTYPE_NODE }, \
{ "emca", CTLTYPE_NODE }, \
{ "datakit", CTLTYPE_NODE }, \
{ "ccitt", CTLTYPE_NODE }, \
{ "ibm_sna", CTLTYPE_NODE }, \
{ "decnet", CTLTYPE_NODE }, \
{ "dec_dli", CTLTYPE_NODE }, \
{ "lat", CTLTYPE_NODE }, \
{ "hylink", CTLTYPE_NODE }, \
{ "appletalk", CTLTYPE_NODE }, \
{ "route", CTLTYPE_NODE }, \
{ "link_layer", CTLTYPE_NODE }, \
{ "xtp", CTLTYPE_NODE }, \
{ "coip", CTLTYPE_NODE }, \
{ "cnt", CTLTYPE_NODE }, \
{ "rtip", CTLTYPE_NODE }, \
{ "ipx", CTLTYPE_NODE }, \
{ "sip", CTLTYPE_NODE }, \
{ "pip", CTLTYPE_NODE }, \
{ "isdn", CTLTYPE_NODE }, \
{ "key", CTLTYPE_NODE }, \
{ "inet6", CTLTYPE_NODE }, \
{ "natm", CTLTYPE_NODE }, \
{ "atm", CTLTYPE_NODE }, \
{ "hdrcomplete", CTLTYPE_NODE }, \
{ "netgraph", CTLTYPE_NODE }, \
{ "snp", CTLTYPE_NODE }, \
{ "scp", CTLTYPE_NODE }, \
}

/*
 * PF_ROUTE - Routing table
 *
 * Three additional levels are defined:
 *	Fourth: address family, 0 is wildcard
 *	Fifth: type of info, defined below
 *	Sixth: flag(s) to mask with for NET_RT_FLAGS
 */
#define NET_RT_DUMP	1		/* dump; may limit to a.f. */
#define NET_RT_FLAGS	2		/* by flags, e.g. RESOLVING */
#define NET_RT_IFLIST	3		/* survey interface list */
#define	NET_RT_MAXID	4

#define CTL_NET_RT_NAMES { \
{ 0, 0 }, \
{ "dump", CTLTYPE_STRUCT }, \
{ "flags", CTLTYPE_STRUCT }, \
{ "iflist", CTLTYPE_STRUCT }, \
}

/*
 * Maximum queue length specifiable by listen.
 */
#ifndef	SOMAXCONN
#define	SOMAXCONN	128
#endif

/*
 * Message header for recvmsg and sendmsg calls.
 * Used value-result for recvmsg, value only for sendmsg.
 */
struct msghdr {
	void		*msg_name;		/* optional address */
	socklen_t	 msg_namelen;		/* size of address */
	struct iovec	*msg_iov;		/* scatter/gather array */
	int		 msg_iovlen;		/* # elements in msg_iov */
	void		*msg_control;		/* ancillary data, see below */
	socklen_t	 msg_controllen;	/* ancillary data buffer len */
	int		 msg_flags;		/* flags on received message */
};

#define	MSG_OOB		0x1		/* process out-of-band data */
#define	MSG_PEEK	0x2		/* peek at incoming message */
#define	MSG_DONTROUTE	0x4		/* send without using routing tables */
#define	MSG_EOR		0x8		/* data completes record */
#define	MSG_TRUNC	0x10		/* data discarded before delivery */
#define	MSG_CTRUNC	0x20		/* control data lost before delivery */
#define	MSG_WAITALL	0x40		/* wait for full request or error */
#define	MSG_DONTWAIT	0x80		/* this message should be nonblocking */
#define	MSG_EOF		0x100		/* data completes connection */
#define MSG_COMPAT      0x8000		/* used in sendit() */

/*
 * Header for ancillary data objects in msg_control buffer.
 * Used for additional information with/about a datagram
 * not expressible by flags.  The format is a sequence
 * of message elements headed by cmsghdr structures.
 */
struct cmsghdr {
	socklen_t	cmsg_len;		/* data byte count, including hdr */
	int		cmsg_level;		/* originating protocol */
	int		cmsg_type;		/* protocol-specific type */
	/* followed by	unsigned char  cmsg_data[]; */
};

/*
 * While we may have more groups than this, the cmsgcred struct must
 * be able to fit in an mbuf, and NGROUPS_MAX is too large to allow
 * this.
 */
#define CMGROUP_MAX 16

/*
 * Credentials structure, used to verify the identity of a peer
 * process that has sent us a message. This is allocated by the
 * peer process but filled in by the kernel. This prevents the
 * peer from lying about its identity. (Note that cmcred_groups[0]
 * is the effective GID.)
 */
struct cmsgcred {
	pid_t	cmcred_pid;		/* PID of sending process */
	uid_t	cmcred_uid;		/* real UID of sending process */
	uid_t	cmcred_euid;		/* effective UID of sending process */
	gid_t	cmcred_gid;		/* real GID of sending process */
	short	cmcred_ngroups;		/* number or groups */
	gid_t	cmcred_groups[CMGROUP_MAX];	/* groups */
};

/* given pointer to struct cmsghdr, return pointer to data */
#define	CMSG_DATA(cmsg)		((unsigned char *)(cmsg) + \
_ALIGN(sizeof(struct cmsghdr)))

/* given pointer to struct cmsghdr, return pointer to next cmsghdr */
#define	CMSG_NXTHDR(mhdr, cmsg)	\
(((caddr_t)(cmsg) + _ALIGN((cmsg)->cmsg_len) + \
_ALIGN(sizeof(struct cmsghdr)) > \
(caddr_t)(mhdr)->msg_control + (mhdr)->msg_controllen) ? \
(struct cmsghdr *)NULL : \
(struct cmsghdr *)((caddr_t)(cmsg) + _ALIGN((cmsg)->cmsg_len)))

#define	CMSG_FIRSTHDR(mhdr)	((struct cmsghdr *)(mhdr)->msg_control)

/* RFC 2292 additions */

#define	CMSG_SPACE(l)		(_ALIGN(sizeof(struct cmsghdr)) + _ALIGN(l))
#define	CMSG_LEN(l)		(_ALIGN(sizeof(struct cmsghdr)) + (l))

#ifdef _KERNEL
#define	CMSG_ALIGN(n)	_ALIGN(n)
#endif

/* "Socket"-level control message types: */
#define	SCM_RIGHTS	0x01		/* access rights (array of int) */
#define	SCM_TIMESTAMP	0x02		/* timestamp (struct timeval) */
#define	SCM_CREDS	0x03		/* process creds (struct cmsgcred) */

/*
 * 4.3 compat sockaddr, move to compat file later
 */
struct osockaddr {
	u_short	sa_family;		/* address family */
	char	sa_data[14];		/* up to 14 bytes of direct address */
};

/*
 * 4.3-compat message header (move to compat file later).
 */
struct omsghdr {
	caddr_t	msg_name;		/* optional address */
	int	msg_namelen;		/* size of address */
	struct	iovec *msg_iov;		/* scatter/gather array */
	int	msg_iovlen;		/* # elements in msg_iov */
	caddr_t	msg_accrights;		/* access rights sent/received */
	int	msg_accrightslen;
};

/*
 * howto arguments for shutdown(2), specified by Posix.1g.
 */
#define	SHUT_RD		0		/* shut down the reading side */
#define	SHUT_WR		1		/* shut down the writing side */
#define	SHUT_RDWR	2		/* shut down both sides */

/*
 * sendfile(2) header/trailer struct
 */
struct sf_hdtr {
	struct iovec *headers;	/* pointer to an array of header struct iovec's */
	int hdr_cnt;		/* number of header iovec's */
	struct iovec *trailers;	/* pointer to an array of trailer struct iovec's */
	int trl_cnt;		/* number of trailer iovec's */
};

#include <sys/cdefs.h>

#ifndef ssize_t
#define ssize_t signed int
#endif

int	accept(int, struct sockaddr *, socklen_t *);
int	bind(int, const struct sockaddr *, socklen_t);
int	connect(int, const struct sockaddr *, socklen_t);
int	getpeername(int, struct sockaddr *, socklen_t *);
int	getsockname(int, struct sockaddr *, socklen_t *);
int	getsockopt(int, int, int, void *, socklen_t *);
int	listen(int, int);
ssize_t	recv(int, void *, size_t, int);
ssize_t	recvfrom(int, void *, size_t, int, struct sockaddr *, socklen_t *);
ssize_t	recvmsg(int, struct msghdr *, int);
ssize_t	send(int, const void *, size_t, int);
ssize_t	sendto(int, const void *,
	       size_t, int, const struct sockaddr *, socklen_t);
ssize_t	sendmsg(int, const struct msghdr *, int);
int	sendfile(int, int, off_t, size_t, struct sf_hdtr *, off_t *, int);
int	setsockopt(int, int, int, const void *, socklen_t);
int	shutdown(int, int);
int	socket(int, int, int);
int	socketpair(int, int, int, int *);

#endif
