package Local::JSONEasyParser;

use 5.010;
use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw( smart_patterns );
our @EXPORT = qw( smart_patterns );

use Encode;
use utf8;

BEGIN{
    if ($] < 5.018) {
        package experimental;
        use warnings::register;
    }
}
no warnings 'experimental';

sub parse_str {
    $_ = shift;
    chop;                # delete last "
    s/"//;               # delete first "

    s/\\n/\n/g;
    s/\\t/\t/g;
    s/\\b/\b/g;
    s/\\f/\f/g;
    s/\\r/\r/g;

    s/\\"/"/g;
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

my $pattern_num = qr/
    \-?                                       # unary
    (?:[1-9]\d*|0)                            # integer part
    (?:\.\d+)?                                # fixed float part
    (?:[eE][\+-]?\d+)?                        # eE float part
/x;
my $pattern_str = qr/
    \"                                        # begin of string
    (?:
    [^"\\]                                    # unicode char except \" and \\
    |
    \\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})        # controlling symbols
    )*
    \"                                        # end of string
/x;
my $pattern_var = qr/(?:true|false|null)/;

our %patterns = (
    number => \{pattern => $pattern_num, parser => \&parse_num},
    string => \{pattern => $pattern_str, parser => \&parse_str},
    var    => \{pattern => $pattern_var, parser => \&parse_var}
    );

sub smart_patterns {
    return \%patterns;
}

1;