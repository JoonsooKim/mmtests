SEQ=10
NAME=$1
LOG_DIR=./work/log

if [ "$1" = "" ]; then
	echo "must specify test name"
	exit 0
fi

if [ "$2" != "" ]; then
	SEQ=$2
fi

echo "Name: " $NAME
echo "Number of Runs: " $SEQ

for i in `seq 1 $SEQ`; do
	echo "$i run start"
	./run-mmtests.sh --run-monitor $NAME
	if [ -e $LOG_DIR ]; then
		mv $LOG_DIR $LOG_DIR-$NAME-$i
	fi
done
