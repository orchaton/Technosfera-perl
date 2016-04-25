package Local::Iterator;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Iterator - base abstract iterator

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

sub all {
	my ($self) = @_;

	my @res;
    while (1) {
        my ($next, $end) = $self->next();
        return \@res if ($end);

        push @res, $next;
    }
}

=head1 SYNOPSIS

=cut

1;
