package Mainframe;
use strict;
use warnings;

use IO::Handle;

use IO::Socket;
use IO::Socket qw( getnameinfo );

use IPC::Shareable;
use IPC::Shareable qw ( LOCK_SH LOCK_NB LOCK_EX );

use POSIX qw ( :sys_wait_h setsid );

use base qw(Exporter);
our @EXPORT_OK = qw( mainframe );
our @EXPORT = qw( mainframe );

use feature 'say';
$| = 1;

use v5.018;
use DDP;

my $client_count;

our %options = (
    create    => 0,
    exclusive => 0,
    mode      => 0644,
    destroy   => 0,
);

sub dec_client_count {
	(tied $client_count)->shlock();
	$client_count -= 1;
	(tied $client_count)->shunlock();
}

sub inc_client_count {
	(tied $client_count)->shlock();
	$client_count += 1;
	(tied $client_count)->shunlock();	
}

sub get_client_count {
	(tied $client_count)->shlock();
	my $_client_count = $client_count;
	(tied $client_count)->shunlock();
	return $_client_count;
}

sub show_client_count {
	(tied $client_count)->shlock();
	say "Mainframe($$): now \$client_count = $client_count";
	(tied $client_count)->shunlock();	
}

sub wait_clients {
	# Прибираемся:
	say "Mainframe($$): dying... Clients: " . get_client_count;
	until ( (my $pid = waitpid(-1, 0)) == -1 ) { }
	say "Mainframe($$): so now I'm dead\n";
}

sub mainframe {

	my ($server, $client_queue_ref, $client_glue, $max_client, $LOG) = @_;

	say "Mainframe($$): " . $client_glue;
	tie $client_count, 'IPC::Shareable', $client_glue, { %options } or 
		die "Mainframe($$)::tie died: $!";
	
	my @client_queue = @$client_queue_ref;
	p @client_queue;

	say "Mainframe($$): Client's Queue connected. Amount = " . ($#client_queue + 1);
	say "Mainframe($$): Busy: " . get_client_count . " clients";

	until ($#client_queue == -1) {

		while (1) {
			# Locked compare 
			# while ($client < $max_client)

			last if ($#client_queue == -1);

			(tied $client_count)->shlock;

			if ($client_count >= $max_client) {
				(tied $client_count)->shunlock; 
				last;
			}

			(tied $client_count)->shunlock;

			# say "Mainframe($$): Push new client";

			serve_client($server, pop @client_queue, $client_glue, $LOG);
			inc_client_count();
		}
	}

	wait_clients();
	exit;
}

sub serve_client {
	my ($server, $client, $client_glue, $LOG) = @_;
	my $pid = fork();
	unless ($pid) {
		
		tie $client_count, 'IPC::Shareable', $client_glue, { %options } or 
			die "Mainframe($$)::tie died: $!";

		my $ppid = getppid();
		say "Mainframe($ppid)::serve: Client openned $$";

		close ($server);

		unless (defined $client) {
			say "Mainframe($ppid)::serve: client (undef) closed: $$";
			dec_client_count;
			show_client_count;
			exit;
		}

		my $other = getpeername($client);
		my ($err, $host, $service) = getnameinfo($other);
		# say "Client $host:$service $/";

		$client->autoflush(1);
		my $msg = <$client>;
		chomp($msg);
	
		print $client "Answer: got it!\n";
		print $client "Recieve END\n" if $msg eq 'END';
		
		$client->shutdown(2);
		close($client);

		say "Mainframe($ppid)::serve: client closed: $$";
		dec_client_count;
		show_client_count;
	
		exit;
	}
}

1;