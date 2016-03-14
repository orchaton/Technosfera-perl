package Local::FilterSort;

use strict;
use warnings;

use List::Util;

=encoding utf8

=head1 NAME

Local::FilterSort - module which filters and sort (if it's necessary) parsed data of music library.

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

# Немного компараторов:
sub num_comparator { my ($a, $b) = @_; return $a != $b; }
sub str_comparator { my ($a, $b) = @_; return $a ne $b; }
sub num_sorter { my ($a, $b, $k) = @_; return $a->{$k} <=> $b->{$k}; }
sub str_sorter { my ($a, $b, $k) = @_; return $a->{$k} cmp $b->{$k}; }

my $comparators = { year   => {compare => \&num_comparator, sort => \&num_sorter},
					band   => {compare => \&str_comparator, sort => \&str_sorter},
                    album  => {compare => \&str_comparator, sort => \&str_sorter},
                    track  => {compare => \&str_omparator,  sort => \&str_sorter},
                    format => {compare => \&str_comparator, sort => \&str_sorter}
                    };

# Функция фильтрует музыкальную библиотеку (массив хешей) согласно ключам указанным в хеше %keys
# Функция принимает указатель на массив хешей (библиотеку музыки) и указатель на %keys
# Функция возвращает указатель на массив хешей (отфильтрованная библиотека)
sub filterLib {
    my ($lib, $keys) = @_;

    my @necessary_keys = grep {defined($keys->{$_}) and $_ ne 'sort' and $_ ne 'columns'} keys %$keys;    
    my @filtered_lib;
    
    for my $node (@$lib) {
        
        my $f = 1;                                            # flag garanties that all keys were passed
        for my $key (@necessary_keys) {
            $f = 0 if $comparators->{$key}{compare} ($node->{$key}, $keys->{$key});
        }
        push @filtered_lib, $node if $f;
    }

    return \@filtered_lib;
}

# Функция сортирует входную библиотеку согласно $keys{sort}
sub sortLib {
    my ($lib, $keys) = @_;

    my $sort_key = $keys->{sort};
    @$lib = sort {$comparators->{$sort_key}{sort}($a, $b, $sort_key)} @$lib;

    return $lib;
}

1;