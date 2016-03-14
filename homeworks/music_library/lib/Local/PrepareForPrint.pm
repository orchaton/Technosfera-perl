package Local::PrepareForPrint;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::PrepareForPrint - module which counts necessary spaces and convert list of hashes to list of list.

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut
# Функция принимает указатель на хеш музыкальной библиотеки и указатель на массив колонок, которые необходимо
# вывести на экран. Возвращает указатель на отформатированный список, который нужно просто распечатать
sub makeList {
	my ($lib, $columns) = @_;
	my @ready_lib;

	for my $line (@$lib) {
		my @node;
		for my $column (@$columns) {
			push @node, $line->{$column};
		}
		push @ready_lib, \@node;
	}

	return \@ready_lib;
}

# Функция подсчитывает количество символов для каждого поля в хеше песни в каждой записи массива (библиотеки)
# Функция возвращает указатель на массив каждый элемент которого показывает размер столбца, выводимого на экран.
sub necessarySpace {
	my ($lib, $count) = @_;	
	my @required_space = map { 0 * $_ } (0..$count-1);

	for my $line (@$lib) {                                      # search of max necessary spaces 
		my @arr = @$line;                                       # for each field
		for my $iter (0..$#arr) {
			if (length $arr[$iter] > $required_space[$iter]) {
				$required_space[$iter] = length $arr[$iter];
			}
		}
	}

	return \@required_space;
}

1;