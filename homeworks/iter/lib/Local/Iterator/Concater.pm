package Local::Iterator::Concater;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Iterator::Concater - concater of other iterators

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Concater->new(
        iterators => [
            $another_iterator1,
            $another_iterator2,
        ],
    );

=cut

use Mouse;

has 'iterators' => (
	'is' => 'rw',
	'isa' => 'Item'
);

has 'iter_cur_idx' => (
	'is' => 'rw',
	'isa' => 'Int'
);

has 'iter_cur' => (
	'is' => 'rw',
	'isa' => 'Item'
);


sub BUILD {
	my ($self) = @_;
	$self->iter_cur_idx(0);
	$self->iter_cur($self->iterators->[0]);

	return ;
}

sub end {
	my ($self) = @_;

	return ($self->iter_cur_idx == scalar @{$self->iterators}) ? 1 : 0;
}

sub next {
	my ($self) = @_;

	return (undef, 1) if ($self->end());
	
	my ($next, $end) = $self->iter_cur->next();
	return ($next, $end) unless ($end);

	$self->iter_cur_idx($self->iter_cur_idx + 1);
	return (undef, 1) if ($self->end()) ;

	$self->iter_cur($self->iterators->[$self->iter_cur_idx]);

	($next, $end) = $self->iter_cur->next();
	return ($next, 0);
}

sub all {
	my ($self) = @_;

	my @res;
	while (1) {
		my ($next, $end) = $self->next();
		return \@res if ($end);

		push @res, $next;
	}
}

1;
