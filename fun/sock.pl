use Socket;
use strict;
use warnings;
use feature 'say';
$| = 1;

my $name = 'www.yandex.ru';
my $addr_bin = 0;
$addr_bin = gethostbyname($name) until ($addr_bin); 

die "FUCK!" unless ($addr_bin);

my $ip = inet_ntoa($addr_bin); 
say $ip;

$addr_bin = inet_aton($ip);

$name = "";
$name = gethostbyaddr($addr_bin, PF_INET) unless ($name);

say $name;
