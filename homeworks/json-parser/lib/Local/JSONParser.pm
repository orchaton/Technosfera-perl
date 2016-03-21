package Local::JSONParser;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

use feature 'say';

sub parse_json {
	my $source = shift;
	
	my $num = qr/
		\-?										# unary
		(?:[1-9]\d*|0)							# integer part
		(?:\.\d+)?								# fixed float part
		(?:[eE][\+-]?\d+)?						# eE float part
	/x;

	my $str = qr/
		\"										# begin of string
		(?:
		[^"\\]									# unicode char except \" and \\
		|
		\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})		# controlling symbols
		)*
		\"										# end of string
	/x;

	my $var = qr/(?:true|false|null)/;

	if ($source =~ /^$num$/g) {
		say 'This is number';
	} elsif ($source =~ /^$str$/g) {
		say 'This is string';
	} elsif ($source =~ /^$var$/g) {
		say 'This is var';
	} else {
		say 'This is unmatchable';
	}



	# use JSON::XS;
	# return JSON::XS->new->utf8->decode($source);
	return {};
}

parse_json('""');

1;
