package Local::Iterator::Aggregator;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Iterator::Aggregator - aggregator of iterator

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Aggregator->new(
        chunk_length => 2,
        iterator => $another_iterator,
    );

=cut

use Mouse;

has 'iterator' => (
	'is' => 'rw',
	'isa' => 'Item'
);

has 'chunk_length' => (
	'is' => 'rw',
	'isa' => 'Int'
);

sub BUILD {
	my ($self) = @_;

	return ;
}

sub next {
	my ($self) = @_;

	my @res;
	for (1..$self->chunk_length) {
		my ($var, $flag) = $self->iterator->next();
		
		return (undef, 1) if ($flag and not defined $var and not @res);
		return ( [ @res ], 1) if ($flag);
		
		push @res, $var;
	}
	return ( [ @res ], 0);
}

sub all {
	my ($self) = @_;

	my @res;
	while (1) {
		my ($val, $flag) = $self->next();
		last if ($flag and not defined $val);

		push @res, $val;
	}
	return \@res;
}

1;
