package Local::Iterator::Array;
use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Iterator::Array - iterator of array

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Array->new(
        array => [1, 2, 3]
    );

=cut


use Mouse;

our $VERSION = '1.0';

has 'array' => (
    'is' => 'rw',
    'isa' => 'Item'
);

has 'last' => (
    'is' => 'rw',
    'isa' => 'Int'
);

sub BUILD {
    my ($self) = @_;
    $self->last(0);
    return ;
}

sub next {
    my ($self) = @_;
    if ($self->last == scalar @{$self->array}) {
        return (undef, 1);
    }
    $self->last($self->last + 1);
    return ($self->array->[$self->last - 1], 0);
}

sub all {
    my ($self) = @_;
    my @res = map { $self->array->[$_]  } $self->last .. scalar @{$self->array} - 1;
    $self->last ( scalar @{$self->array} );
    return \@res;
}

1;
