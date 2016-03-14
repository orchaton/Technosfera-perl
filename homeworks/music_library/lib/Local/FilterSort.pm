package Local::FilterSort;

use strict;
use warnings;

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
	
	my @filtered_lib = grep {
	(($keys->{band}   && $_->{band}   eq $keys->{band})   || not defined $keys->{band})  and 
	(($keys->{album}  && $_->{album}  eq $keys->{album})  || not defined $keys->{album}) and 
	(($keys->{year}   && $_->{year}   == $keys->{year})   || not defined $keys->{year})  and    # 'cause {year} is number
	(($keys->{track}  && $_->{track}  eq $keys->{track})  || not defined $keys->{track}) and
	(($keys->{format} && $_->{format} eq $keys->{format}) || not defined $keys->{format})
	} @$lib;

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