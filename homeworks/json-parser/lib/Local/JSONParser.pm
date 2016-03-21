package Local::JSONParser;

use 5.010;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

use Encode;

BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
use feature 'say';
use DDP;

sub parse_str {
	$_ = shift;
	chop;				# delete last "
	s/"//;				# delete first "

	s/\\n/\n/g;
	s/\\t/\t/g;
	s/\\b/\b/g;
	s/\\f/\f/g;
	s/\\r/\r/g;

	s/\\u([0-9a-fA-F]{4})/chr(hex($1))/ge;
	return $_;
}

sub parse_num {
	$_ = shift;
	return (0+$_);
}

sub parse_var {
	$_ = shift;
	if (/^false$/sg) {
		return "";
	}
	if (/^true$/sg) {
		return 1;
	}
	if (/^null$/sg) {
		return undef;
	}
	0;
}

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

	my $separators = qr/[:,]/;
	my $brackets = qr/[\{\}\[\]]/;

	my %smart_patterns = (
		number => \{pattern => $num, parser => \&parse_num},
		string => \{pattern => $str, parser => \&parse_str},
		var    => \{pattern => $var, parser => \&parse_var}
		);

	# Easy parsers:
	for (values %smart_patterns) {
		if ($source =~ /^${$$_}{pattern}$/sg) {
			return ${$$_}{parser}($source);
		}
	}

	# Recursive parsers:
	


	# use JSON::XS;
	# return JSON::XS->new->utf8->decode($source);
	return {};
}

p parse_json('"Моя\tстрока!\n\u0048"');
p parse_json('true');
p parse_json('false');
p parse_json('null');
p parse_json('-1.23E-3');



1;
