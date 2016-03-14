#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';
use Data::Dumper;
use FindBin;

require "$FindBin::Bin/../lib/Local/PathParser.pm";
require "$FindBin::Bin/../lib/Local/FilterSort.pm";
require "$FindBin::Bin/../lib/Local/TablePrint.pm";
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
TablePrint::printLib(\@ready_lib, \@required_space);
