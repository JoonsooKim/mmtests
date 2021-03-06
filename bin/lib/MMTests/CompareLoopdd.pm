# CompareLoopdd.pm
package MMTests::CompareLoopdd;
use MMTests::Compare;
our @ISA = qw(MMTests::Compare); 

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "CompareLoopdd",
		_DataType    => MMTests::Compare::DATA_OPSSEC,
		_CompareOp   => "pndiff",
		_Precision   => 4,
		_CompareOp   => "pndiff",
		_ResultData  => []
	};
	bless $self, $class;
	return $self;
}

1;
