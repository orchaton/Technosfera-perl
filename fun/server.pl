#!/usr/bin/perl
use strict;
use warnings;

use IO::Handle;

use IO::Socket;
use IO::Socket qw/getnameinfo/;

use POSIX qw ( :sys_wait_h );
use POSIX qw ( mkfifo );

use List::Util qw/min/;

use Fcntl ':flock';
use feature 'say';
$| = 1;

my $server = IO::Socket::INET->new(
    LocalPort  => 8082,
    Type       => SOCK_STREAM,
    Reuse_Addr => 1,
    Listen     => 2
    ) or die "Can't create server on 8081 port: $@ $/";

say 'Server started!';

open (my $LOG, '>', 'server_log') or die "Can't open logfile";
open (my $DEB, '>', 'server_stat') or die "Can't open statfile";

my ($PIPE_R, $PIPE_W);
pipe($PIPE_R, $PIPE_W);

my %stat = (
	max_client_count => 10,
	client_count => 0,
	connections => 0,
	done => 0,
);

my @client_queue;

print $DEB "Client_queue_size: $stat{max_client_count}\n\n";

sub serve_client {
	my ($server, $client) = @_;
	unless (fork()) {
		close ($server);

		my $other = getpeername($client);
		my ($err, $host, $service) = getnameinfo($other);
		print $LOG "Client $host:$service $/";

		$client->autoflush(1);
		my $msg = <$client>;
		chomp($msg);
	
		print $client "Answer: got it!";
		print $client "Recieve END" if $msg eq 'END';
		close($client);
	
		exit;
	}
}

sub request_getter {
	my $server = shift;
	use Data::Dumper;

	while (my $client = $server->accept()) {
		say "Connection: " . Dumper($client);
		serve_client($server, $client);
	}
}

# while (1) {

# 	print $DEB "Total connections: $stat{connections}\n";
# 	print $DEB "Done connections: $stat{done}\n";
# 	print $DEB "Client_count_in_progress: $stat{client_count}\n";
# 	print $DEB "Client_count_in_queue: " . $#client_queue. "\n\n";

	
# 	if ($client_count >= $max_client_count) {
# 		# push @client_queue, $client;

# 	} else {
# 		$client_count++;
# 		# serve_client($server, $client);
# 	}

# 	while ( my $pid = waitpid(-1, WNOHANG) ) {
# 		last if ($pid == 0 or $pid == -1);
# 		$client_count--;
# 		$done++;
# 	}
	
# 	if ($#client_queue != -1) {
# 		my $empty_slot = min($max_client_count - $client_count, $#client_queue + 1);
# 		for (0..$empty_slot) {
# 			$client_count++;
# 			# serve_client($server, $client);
# 		}
# 	}
# }
request_getter($server);
close($server);

say 'Server closed';
