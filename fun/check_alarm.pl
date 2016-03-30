#!/usr/bin/perl
use strict;
use warnings;

use IO::Handle;

use POSIX qw ( :sys_wait_h );

use feature 'say';
$| = 1;

use v5.018;

my $str = "LAL";

$SIG{ALRM} = sub {
	say "ALARM!";
	say "Fucking ALARM!";
	$str = $str eq "LAL" ? "LOL" : "LOL";
};

alarm(1);

while (1) {
	say $str;
}

until ( waitpid(-1, WNOHANG) == -1) {}
