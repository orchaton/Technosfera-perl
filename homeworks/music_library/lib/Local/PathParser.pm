package Local::PathParser;

use strict;
use warnings;
use Getopt::Long;

use feature 'say';
use Data::Dumper;

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
# Функция преобразует входные строки к массиву хешей.
sub parse {
	my @lib;

	while (my $arg = <>) {
		chomp $arg;
		my @str = split m[\/], $arg;

		my $band = $str[1];
		my ($year, $album) = split m[\-], $str[2];
		my ($track, $format) = split m[\.], $str[3]; 

		chop($year);
		$album =~ s/\s//g;

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