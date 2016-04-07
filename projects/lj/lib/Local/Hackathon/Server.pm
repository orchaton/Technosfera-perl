package Local::Hackathon::Server;

use 5.010;
use strict;
use warnings;

no warnings 'experimental';
use Local::Hackathon::Const;
use Local::Hackathon::Storage;
use Mouse;

use Socket;
use IO::Socket;
use JSON::XS;

use DDP;

our $JSON = JSON::XS->new->utf8->pretty->allow_nonref;

has 'port',    is => 'rw', default => 3456;
has 'workers', is => 'rw', default => 50;
has 'storage', is => 'rw';

has 'socket',  is => 'rw';

sub run {
	my $self = shift;
	my $socket = IO::Socket::INET->new(
		LocalHost => '100.100.148.90',
		Proto     => 'tcp',
		LocalPort => $self->port,
		Listen    => SOMAXCONN,
		Reuse     => 1,
	) or die "Can't listen to @{[ $self->port ]}: $!\n";

	$self->socket($socket);
	$self->storage(Local::Hackathon::Storage->new(storage_dir => $FindBin::Bin . '/../'));
	my @pids;

	$SIG{TERM} = $SIG{INT} = sub {
		kill TERM => $_ for @pids;
	};

	for (1..$self->workers) {
		if (my $pid = fork) {
			# parent
			push @pids, $pid;
		} else {
			# children
			@_ = ($self);
			goto &child;
		}
	}
	warn "Ready to work at :$self->{port}\n";

	waitpid $_,0 for @pids;
}

sub child {
	my $self = shift;

	$SIG{INT} = 'IGNORE';
	my $working = 0;
	$SIG{TERM} = sub {
		exit unless $working;
		undef $working;
	};
	
	while (defined $working and my $client = $self->socket->accept()) {
		$client->autoflush(1);
		my $peer = getpeername($client) or next;
		my ($port,$addr) = Socket::unpack_sockaddr_in( $peer );
		my $client_id = "$addr:$port";
		$addr = Socket::inet_ntoa($addr);
		warn "Client $client_id connected\n";

		while () {
			my $rd = read($client, my $buf, 12);
			if ($rd != 12) {
				if (defined $rd and $rd == 0) { last; } # correct close
				warn "Client $client_id reset: $!";
				last;
			}
			my ($pkt, $id, $len) = unpack 'VVV', $buf;

			if ($len > MAXBUF) {
				syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Request to big or malformed data"));
				last;
			}

			$rd = read($client, $buf, $len);
			if ($rd != $len) { warn "Client $client_id reset: $!"; last; }

			my $data;
			eval {
				$data = $JSON->decode( $buf );
			1} or do {
				warn "Failed to decode request JSON from client $client_id: $@\n";
				syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Failed to decode request JSON: $@"));
				last;
			};

			unless (exists $PACKETS{ $pkt }) {
				syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Unknown packet type $pkt"));
				next;
			}

			warn "Processing $PACKETS{$pkt}\n";

			given( $pkt ) {
				when (PKT_PUT) {
					if ( ref $data ne 'ARRAY' ) {	# if $data not SCALAR:
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Wrong arguments format"));
						next;
					}
					eval {
						my $res = $self->storage->put(@$data);
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode($res));
					1} or do {
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("$@"));
					};

				}
				when (PKT_TAKE) {
					if ( ref $data ne 'ARRAY' ) {	# if $data not SCALAR:
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Wrong arguments format"));
						next;
					}
					eval {
						my $res = $self->storage->take(@$data);
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode($res));
					1} or do {
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("$@"));
					};
				}
				when (PKT_ACK) {
					if ( ref $data ne 'ARRAY' ) {	# if $data not SCALAR:
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Wrong arguments format"));
						next;
					}
					eval {
						my $res = $self->storage->ack(@$data);
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode($res));
					1} or do {
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("$@"));
					};			
				}
				when (PKT_RELEASE) {
					if ( ref $data ne 'ARRAY' ) {	# if $data not SCALAR:
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Wrong arguments format"));
						next;
					}
					eval {
						my $res = $self->storage->release(@$data);
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode($res));
					1} or do {
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("$@"));
					};
				}
				when (PKT_REQUEUE) {
					if ( ref $data ne 'ARRAY' ) {	# if $data not SCALAR:
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Wrong arguments format"));
						next;
					}
					eval {
						my $res = $self->storage->requeue(@$data);
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode($res));
					1} or do {
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("$@"));
					};
				}
				when (PKT_STAT) {
					if ( ref $data ne 'ARRAY' ) {	# if $data not SCALAR:
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Wrong arguments format"));
						next;
					}
					eval {
						my $res = $self->storage->check_file();
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode($res));
					1} or do {
						syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("$@"));
					};
				}	
				default {
					syswrite $client, pack ("VVV/a*", $pkt, $id, $JSON->encode("Not implemented packet type $PACKETS{$pkt}"));
				}
			}
		}
		close $client;
	}
}

1;
