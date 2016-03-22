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

use Local::JSONEasyParser;

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
    my ($res, $str) = parse($source);

    return $res;
}

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

        die "Expected }" if ($source =~ /^\s*$/);

        while ($source =~ /[\w\{\[,]/sg){
            my $key; my $val;

            die "Expected smth after , or {" unless (defined ($source));

            ($key, $source) = parse($source);
            $source =~ s/\s*:\s*//;

            die "Expected smth after , or :" unless (defined ($source));
                
            ($val, $source) = parse($source);

            die "Expected smth after , or }" unless (defined ($source));

            $h{$key} = $val;
              
            die "Expected }" if ($source =~ /^\s*$/);

            $source =~ s/^\s*,\s*//;
            last if ($source =~ s/^\s*\}//);
        }
        return wantarray ? (\%h, $source) : \%h;
    }
    # Array parser:
    if ($source =~ /\G\s*\[\s*(.*)/sgc) {
        my @arr;
        $source = $1;

        die "Expected ]" if ($source =~ /^\s*$/);
        while ($source =~ /[\w\{\[,]/sg) {
            my $val;

            ($val, $source) = parse($source);

            die "Expected smth after , or [" unless (defined ($source));

            push @arr, $val;

            die "Expected ]" if ($source =~ /^\s*$/);

            $source =~ s/^\s*,\s*//;
            last if ($source =~ s/^\s*\]//);
        }
        return wantarray ? (\@arr, $source) : \@arr;
    }
    return {};
}

1;
