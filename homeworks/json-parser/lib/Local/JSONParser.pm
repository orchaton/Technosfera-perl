package Local::JSONParser;

use 5.010;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

use Encode;
use utf8;

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
    chop;                # delete last "
    s/"//;               # delete first "

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
        \-?                                       # unary
        (?:[1-9]\d*|0)                            # integer part
        (?:\.\d+)?                                # fixed float part
        (?:[eE][\+-]?\d+)?                        # eE float part
    /x;

    my $str = qr/
        \"                                        # begin of string
        (?:
        [^"\\]                                    # unicode char except \" and \\
        |
        \\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})        # controlling symbols
        )*
        \"                                        # end of string
    /x;
    my $var = qr/(?:true|false|null)/;

    my %smart_patterns = (
        number => \{pattern => $num, parser => \&parse_num},
        string => \{pattern => $str, parser => \&parse_str},
        var    => \{pattern => $var, parser => \&parse_var}
        );

    # Easy parsers:
    for (values %smart_patterns) {
        if ($source =~ /^(${$$_}{pattern})(.*)/sg) {
            return wantarray ? (${$$_}{parser}($1), $2) : ${$$_}{parser}($1);
        }
    }

    # Hash parser:
    if ($source =~ /\G\s*\{\s*(.*)/sgc) {
        my %h;
        $source = $1;
        while ($source =~ /\w/sg){

            my $key;
            my $val;
            ($key, $source) = parse_json($source);

            $source =~ s/\s*:\s*//;

            ($val, $source) = parse_json($source);
            
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
        while ($source =~ /\w/sg){

            my $val;
            ($val, $source) = parse_json($source);

            push @arr, $val;

            $source =~ s/^\s*,\s*//;
            if ($source =~ s/^\s*\]//) {
                last;
            }
        }
        return wantarray ? (\@arr, $source) : \@arr
    }

    
    return {};
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

my $str = '[   "key1" , "val1", {   "key1" : "val1", "key2": 2.3e+2  }, 2.3e+2  ]';

my $ref = parse_json($str);
p $ref;

p parse_json_xs($str);

1;
