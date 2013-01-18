echo "Loading modules..."
export PATH=$PATH:/:.:/usr/sbin
/bin/modprobe -d / /sys/modules/keyboard 
/bin/modprobe -d / /sys/modules/pci 
. /etc/profile
/bin/bash
