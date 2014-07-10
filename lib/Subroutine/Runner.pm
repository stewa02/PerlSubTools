package Subroutine::Runner;
use strict;
use warnings;
use attributes;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(MODIFY_CODE_ATTRIBUTES FETCH_CODE_ATTRIBUTES run);
our $VERSION = "0.7";

my %attrs;

sub MODIFY_CODE_ATTRIBUTES {
	my ($package, $coderef, @attrs) = @_;
	$attrs{ scalar $coderef } = \@attrs;
	foreach (@attrs) {
		if (/^RUNNER\((\d+)\)$/) { $Runner::schedule->[$1] = $coderef; }
	}
	my $allowed = qr/RUNNER/;
	my @bad = grep { $_ !~ $allowed } @attrs;
	return @bad;
}

sub FETCH_CODE_ATTRIBUTES {
	my ($package ,$coderef) = @_;
	my $attrs = $attrs{ scalar $coderef };
    return @{$attrs};
}

sub run {
	my @returns;
	shift @{$Runner::schedule} unless defined ${$Runner::schedule}[0];
	foreach my $function (@{$Runner::schedule}) {
		if (defined $function) {
			my $return = $function->();
			push @returns, $return;
		}
	}
	return wantarray ? @returns : (join "\n", @returns);
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Subroutine::Runner - Module to run subroutines in a defined order

=head1 VERSION

Newest release version 0.7

=head1 DESCRIPTION

Module that enables you to run marked subroutines in a defined order form index 1 onwards.
Every subroutine marked with " : RUNNER($index)" is included, all the subroutines run with the exported command "run".

=head1 SYNOPSIS

Define Subroutine with attribute "RUNNER" and argument index. The subs will be run in order specified by the index:

    sub func_a : RUNNER(2) {return "You called func_a !"};
    sub func_b : RUNNER(1) {return "You called func_b !"};
    sub func_c : RUNNER(3) {return "You called func_c !"};
	
	$output = run;
	print $output;

Will generate the output:

    You called func_b !
	You called func_a !
	You called func_c !


=head1 USAGE

=head2 General Information
For general information read SYNOPSIS. 

=head2 Notes / Additional Information
Note: If not defined the index 0 will be ignored, other not defined indexes will throw a warn message.
The output from the run-routine is stored in a array (list context) or in a single variable joined with "\n" (scalar context).

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

=head1 AUTHOR

Stephan Wagner / PAUSE: STEWATWO

=cut