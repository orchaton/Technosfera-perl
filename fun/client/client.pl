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

say "trying...";

print $socket pack("S", 2) . "\n";
my $answer = <$socket>;

use DDP;
p $answer;

say "\nEnd of Answer...";

