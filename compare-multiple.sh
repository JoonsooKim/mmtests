SEQ=10
NAME=$1
LOG_DIR=./work/log
WORK_DIR=./work

if [ "$1" = "" ]; then
	echo "must specify test name"
	exit 0
fi

if [ "$2" != "" ]; then
	SEQ=$2
fi

echo "Name: " $NAME
echo "Number of Compares: " $SEQ

echo "compare start"
for i in `seq 1 $SEQ`; do
	./compare-kernels.sh --result-dir $LOG_DIR-$NAME-$i > $LOG_DIR-$NAME-$i-result
done
echo "compare finish"

cp $LOG_DIR-$NAME-1-result $WORK_DIR/tmp_merge
rm $LOG_DIR-$NAME-1-result

echo "paste start"
for i in `seq 2 $SEQ`; do
	paste $WORK_DIR/tmp_merge $LOG_DIR-$NAME-$i-result > $WORK_DIR/merged
	rm $LOG_DIR-$NAME-$i-result
	mv $WORK_DIR/merged $WORK_DIR/tmp_merge
done
echo "paste finish"

awk -f ./compare-multiple.awk -v SEQ=$SEQ $WORK_DIR/tmp_merge > $LOG_DIR-$NAME-avg
rm $WORK_DIR/tmp_merge
