#ifndef __REBOOT_H
#define __REBOOT_H
/* Perform a hard reset now.  */
#define RB_AUTOBOOT	0x01234567

/* Halt the system.  */
#define RB_HALT_SYSTEM	0xcdef0123

/* Enable reboot using Ctrl-Alt-Delete keystroke.  */
#define RB_ENABLE_CAD	0x89abcdef

/* Disable reboot using Ctrl-Alt-Delete keystroke.  */
#define RB_DISABLE_CAD	0

/* Stop system and switch power off if possible.  */
#define RB_POWER_OFF	0x4321fedc

/* Reboot or halt the system.  */
extern int reboot (int __howto);

#endif
