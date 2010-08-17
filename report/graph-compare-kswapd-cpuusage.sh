#!/bin/bash
# Plot CPU usage of all kswapds over time. Depends on the top monitor.

DIRNAME=`dirname $0`
SCRIPTDIR=`cd "$DIRNAME" && pwd`
PLOT=$SCRIPTDIR/plot
. $SCRIPTDIR/../config
. $SCRIPTDIR/common-cmdline-parser.sh

for SINGLE_KERNEL in $KERNEL; do
	FIRST_KERNEL=$SINGLE_KERNEL
	break
done

LONGEST_TEST=0
for SINGLE_KERNEL in $KERNEL; do
	START=`head -1 tests-timestamp-$SINGLE_KERNEL | awk '{print $3}'`
	END=`tail -1 tests-timestamp-$SINGLE_KERNEL | awk '{print $3}'`
	DURATION=$((END-START))
	if [ $DURATION -gt $LONGEST_TEST ]; then
		LONGEST_KERNEL=$SINGLE_KERNEL
	fi
done

COPY=$KERNEL
KERNEL=$LONGEST_KERNEL
START=`head -1 tests-timestamp-$LONGEST_KERNEL | awk '{print $3}'`
. $SCRIPTDIR/common-testname-markup.sh
KERNEL=$COPY

PLOTS=
TITLES=

for SINGLE_KERNEL in $KERNEL; do
	PLOTS="$PLOTS kswapdcpu-$SINGLE_KERNEL.plot"
	START=`head -1 tests-timestamp-$SINGLE_KERNEL | awk '{print $3}'`

	echo > kswapdcpu-$SINGLE_KERNEL.plot-unsorted
	for FILE in `ls top-$SINGLE_KERNEL-*.gz`; do
		zcat $FILE | perl -e "\$timestamp = 0;
\$pcpu = -1;
while (<>) {
	if (/^time: ([0-9]*).*/) {
		if (\$timestamp > 0 && \$pcpu != -1) {
			print \"\$timestamp \$pcpu\n\";
			\$pcpu = -1;
		}
		\$timestamp=(\$1-$START)/60;
	}

	#        PID       USER       PR       NI       VIRT_1    RES    SHR         S     CPU        MEM       TIME    COMMAND
	if (/\s*([0-9]+)\s[a-zA-Z]+\s+[0-9]+\s+[0-9]+\s+([0-9]+)\s+[0-9]+\s+[0-9]+\s+[A-Z]\s+([0-9])+\s+[0-9.]+\s+[0-9:.]+\skswapd[0-9]*/) {
		if (\$2 == 0) {
			if (\$pcpu == -1) {
				\$pcpu = 0;
			}
			\$pcpu += \$3;
		}
	}
	}" >> kswapdcpu-$SINGLE_KERNEL.plot-unsorted
	done
	sort -n kswapdcpu-$SINGLE_KERNEL.plot-unsorted | grep -v '^$' > kswapdcpu-$SINGLE_KERNEL.plot
	#rm kswapdcpu-$SINGLE_KERNEL.plot-unsorted
	if [ "$TITLES" != "" ]; then
		TITLES=$TITLES,
	fi
	TITLES="$TITLES$SINGLE_KERNEL"
done

$PLOT \
	--title "$NAME Kswapd CPU Usage" \
	--format "postscript color" \
	--titles $TITLES \
	--extra /tmp/$NAME-extra \
	--dump \
	--output $OUTPUTDIR/kswapdcpu-$NAME.ps \
	$PLOTS > $OUTPUTDIR/kswapdcpu-$NAME.gp
echo Generated kswapdcpu-$NAME.ps

$PLOT \
	--title "$NAME Kswapd CPU Usage" \
	--using "smooth bezier" \
	--format "postscript color" \
	--titles $TITLES \
	--extra /tmp/$NAME-extra \
	--dump \
	--output $OUTPUTDIR/kswapdcpu-smooth-$NAME.ps \
	$PLOTS > $OUTPUTDIR/kswapdcpu-smooth-$NAME.gp
echo Generated kswapdcpu-smooth-$NAME.ps
