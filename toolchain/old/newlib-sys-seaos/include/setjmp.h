#ifndef __SETJMP_H
#define __SETJMP_H

typedef	int jmp_buf[65];
typedef	int sigjmp_buf[65];

void	longjmp(jmp_buf __jmpb, int __retval);
int	setjmp(jmp_buf __jmpb);

#endif

