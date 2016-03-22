package Local::JSONParser;

use 5.010;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

use Encode;
use utf8;

binmode(STDOUT,':utf8');

# use Local::JSONEasyParser;
use JSONEasyParser;

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
	sub parse {
	    my $source = shift;

	    # Easy parsers:
	    my %patterns = %{smart_patterns()}; 
	    for (values %patterns) {
	        if ($source =~ /^(${$$_}{pattern})(.*)/sg) {
	            return wantarray ? (${$$_}{parser}($1), $2) : ${$$_}{parser}($1);
	        }
	    }
	    # Hash parser:
	    if ($source =~ /\G\s*\{\s*(.*)/sgc) {
	        my %h;
	        $source = $1;
	        while ($source =~ /\w/sg){
	            my $key; my $val;

	            ($key, $source) = parse($source);

	            $source =~ s/\s*:\s*//;

	            ($val, $source) = parse($source);

	            $h{$key} = $val;

	            $source =~ s/^\s*,\s*//;
	            if ($source =~ s/^\s*\}//) {
	                last;
	            }
	        }
	        return wantarray ? (\%h, $source) : \%h;
	    }
	    # Array parser:
	    if ($source =~ /\G\s*\[\s*(.*)/sgc) {
	        my @arr;
	        $source = $1;
	        while ($source =~ /\w/sg) {
	            my $val;

	            ($val, $source) = parse($source);

	            push @arr, $val;

	            $source =~ s/^\s*,\s*//;
	            if ($source =~ s/^\s*\]//) {	# Undefined behavior
	                last;
	            }
	        }
	        return wantarray ? (\@arr, $source) : \@arr;
	    }
	    return {};
	}

	my $source = shift;
	my ($res, $str) = parse($source);

	return $res;
}

sub parse_json_xs {
    my $source = shift;
    use JSON::XS;

    return JSON::XS->new->utf8->decode($source);
}

# p parse_json('"Моя\tстрока!\n\u0048"');
# p parse_json('true');
# p parse_json('false');
# p parse_json('null');
# p parse_json('-1.23E-3');
# p parse_json('[ "key1", "val1", { "key1" : "val1", "key2": 2.3e+2 }, 2.3e+2 ]');
# p parse_json('{ "key1": "string value", "key2": -3.1415, "key3": ["nested array"], "key4": { "nested": "object" } }');
# p parse_json_xs('{ "key1": "string value", "key2": -3.1415, "key3": ["nested array"], "key4": { "nested": "object" } }');

# my $hard = qq/ { "key1":\n"string value",\n"key2":\n-3.1415,\n"key3"\n: ["nested array"],\n"key4"\n:\n{"nested":"object"}}/;
# p parse_json($hard);
# p parse_json_xs($hard);

# my $bad = '[{ [{]} }]';

# p parse_json($bad);
# p parse_json_xs($bad);

my $t = '[{ "a":[ "\t\u0451\",","\"," ] }]';
p parse_json($t);
p parse_json_xs($t);

1;
