#!/usr/bin/perl
use strict;
use warnings;

use IO::Handle;

use IO::Socket;
use IO::Socket qw/getnameinfo/;

use POSIX qw ( :sys_wait_h );
use POSIX qw ( mkfifo );

use List::Util qw/min/;

use Fcntl;
use Fcntl ':flock';
use Fcntl qw ( SEEK_SET SEEK_END );
use feature 'say';
$| = 1;

use v5.018;

unless (-e -p 'storage.pipe') {
	mkfifo('storage.pipe', 0700) or die "mkfifo: $!";
}

open (my $FIFO, '<', 'storage.pipe') or die "open: $!";
say 'Fifo openned';

while (1) {
	while (<$FIFO>) {
		say "Got: $_";
		
		chomp($_);
		goto EXIT if ($_ eq 'END');
	}
}
EXIT:

close($FIFO);
unlink('storage.pipe');
say 'Fifo closed';
