use strict;
use warnings;

use FindBin;
use feature 'say';
use DDP;

use lib "$FindBin::Bin/../lib";

use Local::JSONParser;

p parse_json('[]');
p parse_json('[ ]');
p parse_json('[ 1 ]');
p parse_json('{}');
p parse_json('{ }');
p parse_json("{\n}");
p parse_json('[{}]');
p parse_json(q/[{ "a":[ "\t\u0451\",","\"," ] }]/);
p parse_json('{ "key1": "string value", "key2": -3.1415, "key3": ["nested array"], "key4": { "nested": "object" } }');
p parse_json(qq/{\n\t"key1" : "string value",\n\t"key2" : -3.1415,\n\t"key3" : ["nested array"],\n\t"key4":{"nested":"object"}\n}\n/);
p parse_json(qq/ { "key1":\n"string value",\n"key2":\n-3.1415,\n"key3"\n: ["nested array"],\n"key4"\n:\n{"nested":"object"}}/);
	

# use JSON::XS;
# my $r = JSON::XS->new->utf8->decode('[{}]');
# p $r;

