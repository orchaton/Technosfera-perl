#!/usr/bin/perl
package Local::GenCalc;
use strict;
use warnings;

use Fcntl ':flock';
use IO::Socket;
use IO::File;
use Time::HiRes qw/ ualarm /;

use feature 'say';

our $VERSION = '1.0';
my $file_path = './calcs.txt';

my $timeout = 1000 * 1000 * 10;
my $buf_len = 256;

$SIG{ALRM} = sub {
	say 'LOL';
	new_one();
};


sub start_server {
	my $port = shift;
	my $server = IO::Socket::INET->new(
	    LocalPort  => $port,
	    Type       => SOCK_STREAM,
	    Reuse_Addr => 1,
	    Listen     => 10
    ) or die "Can't create server on $port port: $@ $/";

	say "server started";
	new_one();

	while (1) {
		while (my $client = $server->accept()) {
			$_ = <$client>;

			my $msg = unpack("S", $_);
			my $ans = get($msg);

			my $rows;
			for (@$ans) {
				my $row = pack ("IA" . length($_), length($_), $_);
				$rows .= $row;
			}

			$ans = pack("IA" . length($rows), scalar(@$ans), $rows);

			$client->print($ans);
			
			$client->shutdown(2);
			close($client);
		}
	}
}

sub get {
	my $limit = shift;

	my @cache;

	open (my $fh, '<', $file_path) or die "Cannot open file $file_path";
	flock($fh, LOCK_EX);

	for (0..$limit) {
		seek ($fh, -$buf_len, SEEK_END) or last;
		
		my $buf;
		read $fh, $buf, $buf_len;

		push @cache, unpack("A$buf_len", $buf);

		truncate($fh, tell($fh) - $buf_len);
	}

	flock($fh, LOCK_UN);
	close($fh);

	return \@cache;
}

sub new_one {
    # Функция вызывается по таймеру каждые 100
    my $new_row = join $/, int(rand(5)).' + '.int(rand(5)), 
                  int(rand(2)).' + '.int(rand(5)).' * '.int(int(rand(10))), 
                  '('.int(rand(10)).' + '.int(rand(8)).') * '.int(rand(7)), 
                  int(rand(5)).' + '.int(rand(6)).' * '.int(rand(8)).' ^ '.int(rand(12)), 
                  int(rand(20)).' + '.int(rand(40)).' * '.int(rand(45)).' ^ '.int(rand(12)), 
                  (int(rand(12))/(int(rand(17))+1)).' * ('.(int(rand(14))/(int(rand(30))+1)).' - '.int(rand(10)).') / '.rand(10).'.0 ^ 0.'.int(rand(6)),  
                  int(rand(8)).' + 0.'.int(rand(10)), 
                  int(rand(10)).' + .5',
                  int(rand(10)).' + .5e0',
                  int(rand(10)).' + .5e1',
                  int(rand(10)).' + .5e+1', 
                  int(rand(10)).' + .5e-1', 
                  int(rand(10)).' + .5e+1 * 2';
    # say $new_row;
    my $pck = pack("A$buf_len", $/ . $new_row);

    open (my $fh, '>>:raw', $file_path);
    flock ($fh, LOCK_EX);
    
    $fh->print($pck);
    
    flock ($fh, LOCK_UN);
    close($fh);

    ualarm($timeout);
   
    return;
}

start_server(9000);

1;
