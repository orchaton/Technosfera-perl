#!/usr/bin/perl
use strict;
use warnings;

use feature 'say';

open (my $random, '<:raw', '/dev/urandom') or die "Can't open random";
print hex(ord($_)) while (<$random>);
close ($random);
