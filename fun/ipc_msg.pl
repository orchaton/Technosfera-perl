#!/usr/bin/perl
use strict;
use warnings;

use IO::Handle;

use POSIX qw ( :sys_wait_h );

use IPC::SysV qw( IPC_PRIVATE S_IRUSR S_IWUSR IPC_CREAT IPC_EXCL ftok );
use IPC::Shareable;

use List::Util qw/min/;

use feature 'say';
$| = 1;

use v5.018;
use DDP;

our $glue = 'data';
our %options = (
    create    => 'yes',
    exclusive => 0,
    mode      => 0644,
    destroy   => 'yes',
);

sub func {
	my @myvar;

	tie @myvar, 'IPC::Shareable', $glue, \%options or die "Son::tie: $!";

	push @myvar, (1, 2, 3);
}

my @myvar;
tie @myvar, 'IPC::Shareable', $glue, \%options or die "Dad::tie: $!";
@myvar = [];


unless (fork()) {
    sleep(4);
    
    say "Son 1: Gonna make some shit";
    func();

	exit;
}

unless (fork()) {
	say "Son 2: $#myvar";
	((say "Son 2: I have no items in \@myvar"), sleep(1)) while ($#myvar == 0);
	
	exit;	
}

until ( waitpid(-1, WNOHANG) == -1) {}

p @myvar;
