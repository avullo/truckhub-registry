use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
  use FindBin qw/$Bin/;
  use lib "$Bin/../../lib";
}

local $SIG{__WARN__} = sub {};

use File::Temp qw/tempfile/;
use JSON;
use Registry::Utils;
use Registry::TrackHub::Translator;

use_ok 'Registry::TrackHub::Validator';

my $version = '1.0';

throws_ok { Registry::TrackHub::Validator->new() } qr/Undefined/, "Throws if required arg is undefined";

my $validator = Registry::TrackHub::Validator->new(schema => "$Bin/../../../../docs/trackhub-schema/v1.0/trackhub-schema_1_0.json");
isa_ok($validator, 'Registry::TrackHub::Validator');

SKIP: {
  skip "No Internet connection: cannot test TrackHub validation on public Track Hubs", 14
    unless Registry::Utils::internet_connection_ok();

  my $translator = Registry::TrackHub::Translator->new(version => $version);
  isa_ok($translator, 'Registry::TrackHub::Translator');

  my ($URL, $json_docs);

  # Validate Bluprint Track Data Hub
  note "Testing validation of schema 1.0";
  note "Validating translation of Bluprint trackhub";
  $URL = "ftp://ftp.ebi.ac.uk/pub/databases/blueprint/releases/current_release/homo_sapiens/hub";
  $json_docs = $translator->translate($URL, 'hg19');

  # print the translation to file so we can fire the validator
  my $filename = to_temp_file($json_docs->[0]);
  ok($validator->validate($filename), "Validate correct document");

  # test manipulating JSON doc to make it not valid
  # first test validation with missing required elements
  my @required = qw/species assembly data configuration/;
  foreach (@required) {
    my $doc = from_json($json_docs->[0]);
    delete $doc->{$_};
    my $filename = to_temp_file(to_json($doc, { utf8 => 1, pretty => 1 }));
    throws_ok { $validator->validate($filename) } qr/Failed/, "Validation throws if required element missing ($_)";
  }

  # test validation of other aspects with other public hubs
  note "Validating translation of Plants trackhub";
  $URL = "http://genome-test.cse.ucsc.edu/~hiram/hubs/Plants";
  $json_docs = $translator->translate($URL);
  $filename = to_temp_file($json_docs->[0]);
  ok($validator->validate($filename), "Validate correct document");
  
  # should fail with undefined metadata element
  my $doc = from_json($json_docs->[0]);
  push @{$doc->{data}}, { id => undef, name => 'dummy' };
  $filename = to_temp_file(to_json($doc, { utf8 => 1, pretty => 1 }));
  throws_ok { $validator->validate($filename) } qr/Failed/, "Validation throws with undefined metadata element";

  # should fail with undefined track configuration element
  $doc = from_json($json_docs->[0]);
  $doc->{configuration}{repeatMasker_}{name} = undef;
  $filename = to_temp_file(to_json($doc, { utf8 => 1, pretty => 1 }));
  throws_ok { $validator->validate($filename) } qr/Failed/, "Validation throws with undefined track configuration element";
  
  # should fail if assembly accession does not match ^G(CA|CF)_[0-9]+.[0-9]+$
  $doc = from_json($json_docs->[0]);
  $doc->{assembly}{accession} = 'dummy';
  $filename = to_temp_file(to_json($doc, { utf8 => 1, pretty => 1 }));
  throws_ok { $validator->validate($filename) } qr/Failed/, "Validation throws with wrong assembly accession";

  $filename = to_temp_file($json_docs->[1]);
  ok($validator->validate($filename), "Validate correct document");

  # should fail with wrongly formatted members of a composite track  
  $doc = from_json($json_docs->[1]);
  $doc->{configuration}{repeatMasker_}{members} = [ 'a', 'b', 'c' ];
  $filename = to_temp_file(to_json($doc, { utf8 => 1, pretty => 1 }));
  throws_ok { $validator->validate($filename) } qr/Failed/, "Validation throws with wrong composite members";
  
  $filename = to_temp_file($json_docs->[2]);
  ok($validator->validate($filename), "Validate correct document");

  # should fail if missing species attribute
  $doc = from_json($json_docs->[2]);
  delete $doc->{species}{tax_id};
  $filename = to_temp_file(to_json($doc, { utf8 => 1, pretty => 1 }));
  throws_ok { $validator->validate($filename) } qr/Failed/, "Validation throws with missing required species attribute";  
}

sub to_temp_file {
  my $content = shift;

  my ($fh, $filename) = tempfile( DIR => '.', SUFFIX => '.json', UNLINK => 1);
  print $fh $content;
  close $fh;

  return $filename;
}

done_testing();