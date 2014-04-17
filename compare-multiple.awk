BEGIN {
	finish = 0;
}

function process_success_rate()
{
	interval = 5;
	val = 3;
	avg = 0;

	for (i = 0; i < SEQ; i++) {
		pos = i * interval;
		pos += val;

		avg += strtonum($pos);
	}

	avg = (avg / SEQ)
	printf("Success " $2 "\t\t%-.2f\n", avg);
}

function process_time()
{
	interval = 2;
	val = 2;
	avg = 0;

	for (i = 0; i < SEQ; i++) {
		pos = i * interval;
		pos += val;

		avg += strtonum($pos);
	}

	avg = (avg / SEQ)
	printf($1 "\t\t\t%.2f\n", avg);
}

function process_vmstat(interval, val, type)
{
	avg = 0;
	unit = "";

	for (i = 0; i < SEQ; i++) {
		pos = i * interval;
		pos += val;

		if (type == "percentage") {
			len = length($pos);
			str = substr($pos, 0, len - 1);
			unit = "%";
		} else {
			str = $pos;
		}

		avg += strtonum(str);
	}

	avg = (avg / SEQ)
	len = 0;
	for (i = 1; i < val; i++) {
		printf($i" ");
		len += length($i);
		len += 1;
	}

	for (i = 8; i < 32; i += 8) {
		if (len < i)
			printf ("\t");
	}


	if (type == "velocity") {
		printf("\t%8.3f\n", avg);
	} else {
		output = int(avg) "";
		output = output unit;
		printf("\t%8s\n", output);
	}
}

function process_others()
{
	if (NR == 2) {
		print "stress-highalloc";
	} else if (NR == 3 || $1 == kernel_version) {
		kernel_version = $1;
		printf("\t\t\t%s\n", $1);
	} else if (NR == 4 || $1 == name) {
		name = $1;
		printf("\t\t\t%s\n", $1);
	} else
		print $0;
}

{
	if (finish)
		exit

	switch ($1) {
	case "Success":
		process_success_rate();
		break;
	case "User":
	case "System":
	case "Elapsed":
		process_time();
		break;
	case "Minor":
	case "Major":
	case "Swap":
	case "Sector":
	case "Slabs":
		process_vmstat(3, 3);
		break;
	case "Direct":
	case "Kswapd":
		switch ($2) {
		case "efficiency":
			process_vmstat(3, 3, "percentage");
			break;
		case "velocity":
			process_vmstat(3, 3, "velocity");
			break;
		default:
			process_vmstat(4, 4);
			break;
		}
		break;
	case "Percentage":
		process_vmstat(4, 4, "percentage");
		break;

	case "Zone":
		process_vmstat(4, 4, "velocity");
		break;

	case "Page":
		switch ($3) {
		case "by":
			process_vmstat(5, 5);
			break;
		default:
			process_vmstat(4, 4);
			break;
		}
		break;

	case "THP":
		switch ($2) {
		case "splits":
			process_vmstat(3, 3);
			break;
		default:
			process_vmstat(4, 4);
			break;
		}
		break;

	case "Compaction":
		switch ($2) {
		case "stalls":
		case "success":
		case "failures":
		case "cost":
			process_vmstat(3, 3);
			if ($2 == "cost")
				finish = 1;
			break;
		default:
			process_vmstat(4, 4);
			break;
		}
		break;
	case "NUMA":
	case "AutoNUMA":
		break;

	default:
		process_others();
		break;
	}
}
