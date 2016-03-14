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

			if ($key eq 'year') {
				undef $f if ($node->{$key} != $keys->{$key});
			} else {
				undef $f if ($node->{$key} ne $keys->{$key});
			}
		}
		push @filtered_lib, $node if $f;
	}

    return \@filtered_lib;
}

# Функция сортирует входную библиотеку согласно $keys{sort}
sub sortLib {
	my ($lib, $keys) = @_;

	if ($keys->{sort} eq "year") {
		@$lib = sort { $a->{$keys->{sort}} <=> $b->{$keys->{sort}} } @$lib;	
	} else {
		@$lib = sort { $a->{$keys->{sort}} cmp $b->{$keys->{sort}} } @$lib;
	}
	return $lib;
}

1;