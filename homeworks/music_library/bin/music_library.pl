#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';
use Data::Dumper;
use FindBin;

require "$FindBin::Bin/../lib/Local/PathParser.pm";
require "$FindBin::Bin/../lib/Local/FilterSort.pm";
require "$FindBin::Bin/../lib/Local/PrepareForPrint.pm";

# Получение ключей запуска
my %keys = %{Local::PathParser::getExecOptions()};

# Чтение музыкальной библиотеки
my @lib = @{Local::PathParser::makeLib()};

# Фильтрация библиотки по ключам
my @filtered_lib = @{Local::FilterSort::filterLib(\@lib, \%keys)};

# Сортировка отфильтрованной библиотеки если это необходимо
my @sorted_lib = defined $keys{sort} ? @{Local::FilterSort::sortLib(\@filtered_lib, \%keys)} : @filtered_lib;

# Преобразование библиотеки к массиву массивов. Дублирование колонок согласно ключам
my @ready_lib = @{Local::PrepareForPrint::makeList(\@sorted_lib, $keys{columns})};

# Подсчет ширины каждого столбца
my @required_space = @{Local::PrepareForPrint::necessarySpace(\@ready_lib, scalar(@{$keys{columns}}))};

# Вывод библиотеки на экран
printLib(\@ready_lib, \@required_space);

sub printLib {
	my ($lib, $space) = @_;
	my $lib_len = scalar(@$lib);
	
	if ($lib_len == 0 || scalar(@$space) == 0) {	# краевые значения
		return 0;
	}

	my $head_line = "/" . (join "", (map {"-"x($_ + 3)} @$space));
	chop ($head_line);
	$head_line .= "\\";

	my $skip_line = "\n|" . (join "+", (map {"-"x($_ + 2)} @$space)) . "|\n";

	say $head_line;

	for my $line_iter (0..$lib_len-1) {
		
		my @arr = @{$lib->[$line_iter]};
		
		print "|";
		for my $iter (0..$#arr) {
			print map {" "} ( 0..($space->[$iter] - length $arr[$iter]) );
			print $arr[$iter];
			print " |";
		}
		if ($line_iter < $lib_len - 1){			# проверка на последнюю строку.
 			print $skip_line;
 		} else {								# не нужно выводить $skip_line
 			print "\n";
 		}
	}

	my $bottom_line = "\\" . (join "", (map {"-"x($_ + 3)} @$space));
	chop($bottom_line);
	$bottom_line .= "/";

	say $bottom_line;
}
