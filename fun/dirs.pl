#!/usr/bin/perl
use strict;
use warnings;

use feature 'say';

opendir (my $home, '/home/ochaton') or die $!;

my $pos = 0;
while (my $fname = readdir $home) {
	say $fname;
	$pos = telldir $home if $fname eq '.';
}

say "Position: $pos";

if ($pos) {
	say "I'm in pos: ";
	seekdir ($home, $pos);
	while (my $fname = readdir $home) {
		say "Second: " . "$fname";
	}
}

closedir ($home);
