#!/usr/bin/env perl

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::Hackathon::Client;
use Local::Hackathon::Const;
use DDP;

my $c = Local::Hackathon::Client->new(host => '100.100.148.90');

my $res = $c->request(PKT_STAT, [ 'fetch', { URL => 'localhost' } ]);
p $res;