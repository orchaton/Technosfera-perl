package Local::PrintLib;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::PrintLib - module which prints MusicLibrary to the screen using table.

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

# Функция принимает на вход указатель на массив массивов (отформатированную музыкальную библиотеку) 
# и указатель на массив, значения которого отражают ширину каждого столбца.
# Функция выводит этот массив массивов на экран в виде красивой таблицы.
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
		if ($line_iter < $lib_len - 1){         # проверка на последнюю строку.
 			print $skip_line;
 		} else {                                # не нужно выводить $skip_line
 			print "\n";
 		}
	}

	my $bottom_line = "\\" . (join "", (map {"-"x($_ + 3)} @$space));
	chop($bottom_line);
	$bottom_line .= "/";

	say $bottom_line;
}
