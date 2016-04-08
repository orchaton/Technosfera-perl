package Local::Iterator::File;

use strict;
use warnings;

use Fcntl qw ( SEEK_SET SEEK_CUR SEEK_END );

=encoding utf8

=head1 NAME

Local::Iterator::File - file-based iterator

=head1 SYNOPSIS

    my $iterator1 = Local::Iterator::File->new(file => '/tmp/file');

    open(my $fh, '<', '/tmp/file2');
    my $iterator2 = Local::Iterator::File->new(fh => $fh);

=cut

use Mouse;

our $VERSION = '1.0';

has 'fh' => (
    'is' => 'rw',
    'isa' => 'Item'
);

has 'filename' => (
    'is' => 'rw',
    'isa' => 'Str'
);

has 'last' => (
    'is' => 'rw',
    'isa' => 'Int'
);

sub BUILD {
    my ($self) = @_;
    $self->last(0);

    if (defined $self->filename) {
    	open (my $fh, '<', $self->filename);
    	$self->fh(\$fh);
    }

    return ;
}

sub next {
	my ($self) = @_;

	if ($self->last == -1) {
		return (undef, 1);
	}

	my $fh = ${$self->fh};
	seek($fh, $self->last, SEEK_SET);
	
	my $str = <$fh>;
	$str =~ s/\n//;
	
	$self->last(tell($fh));
	if (eof($fh)) {
		$self->last(-1);
	}

	return ($str, 0);
}

sub all {
	my ($self) = @_;

	my @res;

	if ($self->last == -1) {
		return undef;
	}

	my $fh = ${$self->fh};
	seek($fh, $self->last, SEEK_SET);
	
	while (my $str = <$fh>) {
		$str =~ s/\n//;
		push @res, $str;
	}

	$self->last(-1);
	return \@res;
}

1;
