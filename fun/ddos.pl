#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(:sys_wait_h);

use feature 'say';

my $clients = defined $ARGV[0] ? $ARGV[0] : 15;
for (1..$clients) {
	unless (fork()) {
		exec('./client.pl', "$_");
		exit;
	}
}

my $cnt = 0;
until ( (my $pid = waitpid(-1, 0)) == -1 ) {
	say "Done $cnt/$clients";
	$cnt++;
}

say "DDOS Done.";
