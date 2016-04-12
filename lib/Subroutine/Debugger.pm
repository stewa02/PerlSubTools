package Debugger;
use strict;
use warnings;
use Exporter;
use B;

our @ISA = qw(Exporter);
our @EXPORT = qw(MODIFY_CODE_ATTRIBUTES FETCH_CODE_ATTRIBUTES);
our $VERSION = "0.1";

my %attrs;

sub TIEHANDLE {
	bless [] => shift;
}

sub PRINT { 
	no warnings "uninitialized";
	my $self = shift; 
	print STDOUT "STOUTPUT> ",@_,$\,"\n"; 
}

sub MODIFY_CODE_ATTRIBUTES {
	my ($package, $coderef, @attrs) = @_;
	$attrs{ scalar $coderef } = \@attrs;
	
	my $cv = B::svref_2object ( $coderef );
	my $gv = $cv->GV;
	my $sub = $gv->NAME;
	
	foreach (@attrs) {
		no strict "refs";
		no warnings "redefine";
		if (/^DEBUGGER$/) { 
			*{"$package::$sub"} = sub {
				print "DEBUGGER> Enter Subroutine $sub!\n";
				tie(*REDIR,"Debugger");
				select *REDIR;
				my @returns = &{$coderef}(@_);
				select STDOUT;
				my $pad = $cv->PADLIST;
				my @scratchpad = $pad->ARRAY;
				my @varnames = $scratchpad[0]->ARRAY;
				my @vars;
				for (0 .. $#varnames) {
					eval { push @vars, $varnames[$_]->PV; }
				}
				print "DEBUGGER> Local variables ",(join ", ", @vars)," used!\n";

				print "DEBUGGER> Exit Subroutine $sub!\n";
				my $returns = join ", ", @returns;
				print "DEBUGGER> Subroutine $sub returns: $returns!\n";

				return wantarray ? @returns : $returns;
			};
		}
	}
	my @bad = grep { $_ ne "DEBUGGER" } @attrs;
	return @bad;
}

sub FETCH_CODE_ATTRIBUTES {
	my ($package ,$coderef) = @_;
	my $attrs = $attrs{ scalar $coderef };
	return @{$attrs};
}

1;

__END__

=pod

=cut
