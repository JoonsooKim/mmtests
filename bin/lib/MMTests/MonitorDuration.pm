# MonitorDuration.pm
package MMTests::MonitorDuration;
use MMTests::Monitor;
use VMR::Report;
our @ISA = qw(MMTests::Monitor); 
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "MonitorDuration",
		_DataType    => MMTests::Monitor::MONITOR_CPUTIME_SINGLE,
		_ResultData  => []
	};
	bless $self, $class;
	return $self;
}

sub extractReport($$$) {
	my ($self, $reportDir, $testName, $testBenchmark) = @_;

	my $file;
	my $i;
	my ($user, $system, $elapsed);
	my $iterations = 10;

	for ($i = 1; $i <= $iterations; $i++) {
	$file = "$reportDir/$i/tests-timestamp-$testName";

	open(INPUT, $file) || die("Failed to open $file\n");
	while (<INPUT>) {
		if ($_ =~ /^time \:\: $testBenchmark (.*)/) {
			my $dummy;
			my ($useri, $systemi, $elapsedi);

			($useri, $dummy,
			 $systemi, $dummy,
			 $elapsedi, $dummy) = split(/\s/, $1);

			$user += $useri;
			$system += $systemi;
			$elapsed += $elapsedi;
		}
	}
	close INPUT;
	}

	push @{$self->{_ResultData}}, [ "", $user / $iterations, $system / $iterations, $elapsed / $iterations];
}

1;
