#!/usr/bin/perl
use strict;
use warnings;

use IO::Handle;

use IO::Socket;
use IO::Socket qw/getnameinfo/;

use POSIX qw ( :sys_wait_h );
use POSIX qw ( mkfifo );

use List::Util qw/min/;

use IPC::Shareable;

use Listenner qw ( listenner );

use Fcntl ':flock';
use feature 'say';
$| = 1;

use v5.018;

my $server = IO::Socket::INET->new(
    LocalPort  => 9000,
    Type       => SOCK_STREAM,
    Reuse_Addr => 1,
    Listen     => 2
    ) or die "Can't create server on 8000 port: $@ $/";

open (my $LOG, '>>', 'server_log') or die "Can't open logfile";
open (my $DEB, '>', 'server_stat') or die "Can't open statfile";

unless (-e -p 'storage.pipe') {
	mkfifo('storage.pipe', 0700) or die "mkfifo: $!";
}

my $max_client = 50;

my $glue = 'scalar_glue';
my %options = (
    create    => 1,
    exclusive => 0,
    mode      => 0644,
    destroy   => 1,
);

my $shared_var;
tie $shared_var, 'IPC::Shareable', $glue, { %options } or 
    die "Listenner::tie died: $!"; 

our $listenner_pid = fork();
	die "Listenner can not be started: $!" unless (defined $listenner_pid);

unless ($listenner_pid) {
	listenner($server, $max_client, $LOG);
	exit;
}

my $process_name;
until ( (my $res = waitpid ($listenner_pid, WNOHANG)) == -1 ) {
	next unless ($res);
	$process_name = "Listenner";

	say $process_name . " stopped: $! \n$@";
	print $LOG $process_name . " stopped successfully\n";
	print $DEB $process_name . " stopped successfully\n";
}
