package Local::PathParser;

use strict;
use warnings;
use Getopt::Long;

=encoding utf8

=head1 NAME

Local::PathParser - parser of path for music library

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

# Функция обрабатывает ключи, с которыми запускался скрипт. 
# Функция возвращает указатель на хеш ключей.
sub getExecOptions {

	my %keys = (
		band => undef,
		year => undef,
		album => undef,
		track => undef,
		format => undef,
		sort => undef,
		columns => undef);

	GetOptions(	"band=s" => \$keys{band},
				"year=s" => \$keys{year},
				"album=s" => \$keys{album},
				"track=s" => \$keys{track},
				"format=s" => \$keys{format},
				"sort=s" => \$keys{sort},
				"columns=s" => \$keys{columns});

	if (defined ($keys{columns})) {
		$keys{columns} = [split /,/, $keys{columns}];				# make list from string
	} else {
		$keys{columns} = ['band','year','album','track','format'];	# default value
	}
	return \%keys;
}

# Функция читает из входного потока строки вида ./<band>/<year> - <album>/<track>.<format>
# Функция преобразует входные строки к массиву массивов лексем.
sub parse {
	my @data;

	while (my $arg = <>) {
		chomp $arg;
		my @str = split m{[\.\/\-]}, $arg;

		for (my $i = 0; $i <= $#str; $i++) {
			if ($str[$i] eq '') {
				splice @str, $i, 1;			# Kill empty strings (after split, $str[0] and $str[1] is empty)
				$i--;
			}
		}

		chop $str[1];						# Kill last \s in 'year'-string
		$str[2] =~ s/\s//;					# Kill first \s in 'album'-string

		push @data, \@str;
	}
	return \@data;
}

# Функция возвращает музыкальную библиотеку в формате указателя на массив хешей.
sub makeLib {
	my @data = @{parse()};
	
	my @lib;
	for my $str (@data) {
		my ($band, $year, $album, $track, $format) = @$str;

		my %node = (band => $band, 
		            year => $year, 
		            album => $album, 
		            track => $track, 
		            format => $format
		            );
		push @lib, \%node;
	}
	return \@lib;
}

1;