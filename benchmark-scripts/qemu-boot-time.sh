#!/bin/bash

# fgkaslr option check
if ! [[ "$1" =~ ^(nofgkaslr|fgkaslr)$ ]]; then
    echo "Need to specify nofgkaslr or fgkaslr."
    exit 1
else
    if [ "$1" = nofgkaslr ]; then
        kaslr_opt=$1
    else
        kaslr_opt=""
    fi
fi

rm -rf /tmp/perf.log
touch /tmp/perf.log

PERF_PATH="perf/perf"
PERF_DATA="qemu_perf.data"
QEMU_PATH="qemu-patched/build/qemu-system-x86_64"

${PERF_PATH} record -a -e kvm:kvm_entry -e kvm:kvm_pio -e sched:sched_process_exec \
            -o $PERF_DATA &
PERF_PID=$! &> /dev/null



sleep 3

${QEMU_PATH} -kernel linux-fgkaslr/arch/x86/boot/bzImage \
                                    -drive file=boottime-rootfs.ext4,if=virtio,format=raw \
                                    -append "${kaslr_opt} panic=1 console=ttyS0 pci=off" \
                                    -nographic \
                                    -machine q35,accel=kvm \
                                    -cpu host \
                                    -initrd ramdisk.img \
                                    -m 512M \
                                    -no-reboot &> /dev/null


pkill perf &> /dev/null

sleep 3

${PERF_PATH} script -s perf/qemu-perf-script.py -i $PERF_DATA > /tmp/perf.log
a=$(grep linux_start /tmp/perf.log | awk ' { print $2 }')
b=($a)

echo "${b[1]} - ${b[0]}" | bc -l