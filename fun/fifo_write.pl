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

open (my $FIFO, '>', 'storage.pipe') or die "open: $!";
say 'Fifo openned';

flock($FIFO, LOCK_EX);
for (1..10) {
	print $FIFO "$_\n";
}
print $FIFO "END\n";

close($FIFO);
say 'Fifo closed';
