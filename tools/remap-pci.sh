#!/bin/sh

if ! (dmesg | grep "Intel-IOMMU: enabled" > /dev/null); then
  echo "Intel IOMMU not enabled!" >&2
  exit 1
fi

if [[ "x$1" == "x" ]]; then
  echo "usage: remap-pci.sh <pci device>"
  exit 1
fi

if ! (lspci | grep "$1"); then
  echo "pci device $1 not found!" >&2
  exit 1
fi

echo "loading pci-stub module..."
modprobe pci-stub

id=`lspci -n | grep $1 | awk '{print $3}' | sed -e "s/\:/\ /"`
echo "found device to be of vendor and device: $id"

echo $id > /sys/bus/pci/drivers/pci-stub/new_id
echo "0000:$1" > /sys/bus/pci/devices/0000:$1/driver/unbind
echo "0000:$1" > /sys/bus/pci/drivers/pci-stub/bind

echo "re-loading KVM modules"
modprobe -r kvm-intel
modprobe -r kvm
modprobe kvm
modprobe kvm-intel

if [ $(dmesg | grep ecap | wc -l) -eq 0 ]; then
  echo "No interrupt remapping support found. Enabling unsafe assigned interrupts..."
  echo 1 > /sys/module/kvm/parameters/allow_unsafe_assigned_interrupts
fi
for i in $(dmesg | grep ecap | awk '{print $NF}'); do
  if [ $(( (0x$i & 0xf) >> 3 )) -ne 1 ]; then
    echo "Interrupt remapping not supported. Enabling unsafe assigned interrupts..."
    echo 1 > /sys/module/kvm/parameters/allow_unsafe_assigned_interrupts
    break
  fi
done

echo "PCI device $1 is now ready for kvm passthrough!"
