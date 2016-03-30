#!/usr/bin/perl
use strict;
use warnings;

use IO::Handle;

use POSIX qw ( :sys_wait_h setsid setpgid );
use feature 'say';
$| = 1;

use v5.018;
use DDP;

say "Dad: " . getpgrp;
my $pid;
unless ($pid = fork()) {

	setsid();
	my $me = $$;

	say "Son: " . getpgrp;
	for (0..2) {
		unless(fork()) {
			say "Grandson: "  . getpgrp;
			sleep(10);
			exit;
		}
	}

	sleep(4);
	exit;
}


until (waitpid(-1, WNOHANG) == -1) {}
say "Done.";
