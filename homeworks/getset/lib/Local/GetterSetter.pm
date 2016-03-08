package Local::GetterSetter;

use strict;
use warnings;

use feature 'say';

=encoding utf8

=head1 NAME

Local::GetterSetter - getters/setters generator

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

sub import {
  my ($self, @fields) = @_;
  my $caller =  caller();

  no strict 'refs';
  for my $field (@fields) {
    *{"$caller"."::get_$field"} = sub { return ${"$caller::$field"}; };
    *{"$caller"."::set_$field"} = sub { ${"$caller::$field"} = shift; };
  }
}

1;
