#ifndef	_MACHTYPES_H_
#define	_MACHTYPES_H_

/*
 *  The following section is RTEMS specific and is needed to more
 *  closely match the types defined in the BSD machine/types.h.
 *  This is needed to let the RTEMS/BSD TCP/IP stack compile.
 */
#if defined(__rtems__)
#include <machine/_types.h>
#endif

#define	_CLOCK_T_	unsigned long		/* clock() */
#define	_TIME_T_	long			/* time() */
#define _CLOCKID_T_ 	unsigned long
#define _TIMER_T_   	unsigned long

//typedef long off_t;

#endif	/* _MACHTYPES_H_ */


