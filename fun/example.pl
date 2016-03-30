use strict;
use POSIX qw(:sys_wait_h);
$|=1;

my ($r, $w);
pipe($r, $w);

if(my $pid = fork()){
	close($r);
	print $w $_ for 1..5;
	close($w);
	waitpid($pid, 0);
}
else {
	die "Cannot fork $!" unless defined $pid;
	close($w);
	
	while(<$r>){ print $_ }
	
	close($r);
	exit;
}