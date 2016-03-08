package Local::GetterSetter;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::GetterSetter - getters/setters generator

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

sub import {
  my($me, @fields) = @_;
  return unless @fields;

  my $caller = caller();  
  my $eval = "package $caller;\n";

  foreach my $field (@fields) {
    $eval .= "sub get_$field { return \${$caller::$field}; }\n";
    $eval .= "sub set_$field { \${$caller::$field} = shift; }\n";
  }

  eval $eval;

  # $@ содержит возможные ошибки вычисления
  $@ and die "Error for $caller: $@";
}

=head1 SYNOPSIS

    package Local::SomePackage;
    use Local::GetterSetter qw(x y);

    set_x(50);
    print our $x; # 50

    our $y = 42;
    print get_y(); # 42
    set_y(11);
    print get_y(); # 11

=cut

1;
