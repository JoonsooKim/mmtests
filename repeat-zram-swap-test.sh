#!/bin/bash

SIZE=$1
NAME=`uname -r`

if [ "$1" = "" ]; then
	echo "size should be specified"
	exit 0
fi

sudo swapoff /dev/sdb5
sudo swapoff /dev/zram0

ALLOCATORS="zsmalloc afms"
THREADS="1 2 4 8 12 16 20 24 28 32"

for i in $THREADS; do

	for ALLOCATOR in $ALLOCATORS; do
		echo "$ALLOCATOR allocator, $i threads run"

		cat config | sed \
			-e "s/export KERNBENCH_MAX_THREADS=.*/export KERNBENCH_MAX_THREADS=$i/" > /tmp/mmtest_config
		mv /tmp/mmtest_config config
		sudo bash -c "echo 1 > /sys/block/zram0/reset"
		sudo bash -c "echo $ALLOCATOR > /sys/block/zram0/backend"
		sudo bash -c "echo $SIZE > /sys/block/zram0/disksize"
		sudo mkswap /dev/zram0
		sudo swapon /dev/zram0

		./run-mmtests.sh -m $NAME"-"$ALLOCATOR"-"$i

		sudo swapoff /dev/zram0
		sudo bash -c "echo 1 > /sys/block/zram0/reset"
	done
done

sudo swapon /dev/sdb5
