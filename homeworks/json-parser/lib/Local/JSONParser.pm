package Local::JSONParser;

use 5.010;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
use feature 'say';
use DDP;

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
	
	my $separators = qr/[:,]/;
	my $brackets = qr/[\{\}\[\]]/;

	# Easy parse:
	given ($source) {
		when (/^false$/sg) {
			return "";
		}
		when (/^true$/sg) {
			return 1;
		}
		when (/^null$/sg) {
			return undef;
		}
		when (/^$num$/sg) {
			return (0+$_);
		}
		when (/^$str$/sg) {
			chop;				# delete last "
			s/"//;				# delete first "

			s/\\n/\n/g;
			s/\\t/\t/g;
			s/\\b/\b/g;
			s/\\f/\f/g;
			s/\\r/\r/g;
			return $_;
		}
	}


	# use JSON::XS;
	# return JSON::XS->new->utf8->decode($source);
	return {};
}

p parse_json('"М\rоя ст\tро\tк\tа!\b\n"');
p parse_json('true');
p parse_json('false');
p parse_json('null');
p parse_json('-1.23E-3');


1;
