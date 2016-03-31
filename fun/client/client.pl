#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;

use feature 'say';

my $socket = IO::Socket::INET->new(
	PeerAddr => 'localhost',
	PeerPort => 9000,
	Proto => "tcp",
	Type => SOCK_STREAM)
or die "Can`t connect to localhost: $@ $/";

print $socket "END\n";
my @answer = <$socket>;

close(STDOUT);
open (STDOUT, '>', "/dev/null") or die "Can't open STDOUT";

say "Args: ", join " ", @ARGV;
print @answer;
say "\nEnd of Answer...";

