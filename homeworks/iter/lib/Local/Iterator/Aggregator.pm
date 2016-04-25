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
use parent 'Local::Iterator';

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
		last if ($flag == 1);

		push @res, $var;
	}
	return (\@res, 0) if @res;
	return (undef, 1) unless (@res);
}

1;
