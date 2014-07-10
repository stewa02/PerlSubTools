package Subroutine::Debugger;
use strict;
use warnings;
use Exporter;
use B;

our @ISA = qw(Exporter);
our @EXPORT = qw(MODIFY_CODE_ATTRIBUTES FETCH_CODE_ATTRIBUTES);
our $VERSION = "0.1";

my %attrs;

sub MODIFY_CODE_ATTRIBUTES {
	my ($package, $coderef, @attrs) = @_;
	$attrs{ scalar $coderef } = \@attrs;
	
	my $time = localtime(time);
	my $cv = B::svref_2object ( $coderef );
	my $gv = $cv->GV;
	my $sub = $gv->NAME;
	
	foreach (@attrs) {
		no strict "refs";
		no warnings "redefine";
		if (/^DEBUG$/) { 
			*{"$package::$sub"} = sub {
				print "Enter Subroutine $sub!\n";
				my @returns = &{$coderef}(@_);
				print "Exit Subroutine $sub!\n";
				my $returns = join ", ", @returns;
				return wantarray ? @returns : $returns;
			};
		}
		elsif (/^LOG$/) {
			open(LOG, ">execution_log");
			print LOG "#" x 30;
			print LOG "\nStartup: $time\n";
			print LOG "Package: $package\n";
			print LOG "#" x 30;
			print LOG "\n\n";
			close(LOG);
			*{"$package::$sub"} = sub {
				open(LOG, ">>execution_log");
				print LOG ">$sub\n";
				my @returns = &{$coderef}(@_);
				my $returns = join ", ", @returns;
				print LOG "=$sub:$returns\n";
				print LOG "<$sub\n\n";
				close(LOG);
				return wantarray ? @returns : $returns;
			};
		}
	}
	my @bad1 = grep { $_ ne "DEBUG" } @attrs;
	my @bad2 = grep { $_ ne "LOG" } @bad1;
	return @bad2;
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