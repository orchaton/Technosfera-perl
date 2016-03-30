#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

$| = 1;
use v5.018;
use Data::Dumper;

my @arr = (1..20);
say Dumper(@arr);

my @another_arr;
push @another_arr, shift @arr for (0..5);

# say Dumper(@another_arr);
# say Dumper(@arr);

undef(@another_arr);

push @another_arr, shift @arr for (0..5);
say Dumper(@another_arr);

my $idx = 0;
while ($idx < $#another_arr + 1) {
	splice(@another_arr, $idx, 1);
}

say "__END__:";
say Dumper(@another_arr);

say $#another_arr;
pop @another_arr;

say Dumper(@another_arr);
