use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON;

BEGIN {
  use FindBin qw/$Bin/;
  use lib "$Bin/../lib";
}

use HTTP::Request::Common;
use JSON;
use Catalyst::Test 'ElasticSearchDemo';

use ElasticSearchDemo::Utils; # es_running
use ElasticSearchDemo::Indexer; # index a couple of sample documents

SKIP: {
  skip "Launch an elasticsearch instance for the tests to run fully",
    11 unless &ElasticSearchDemo::Utils::es_running();

  # index test data
  note 'Preparing data for test (indexing sample documents)';
  my $indexer = ElasticSearchDemo::Indexer->new(dir   => "$Bin/../../../docs/trackhub-schema/draft02/examples/",
						index => 'test',
						type  => 'trackhub',
						mapping => 'trackhub_mappings.json');
  $indexer->index();

  #
  # /api/trackhub (GET): get list of documents with their URIs
  #
  ok(my $response = request('/api/trackhub'), 'GET request to /api/trackhub');
  ok($response->is_success, 'Request successful 2xx');
  is($response->content_type, 'application/json', 'JSON content type');
  my $content = from_json($response->content);
  map { like($content->{$_}, qr/api\/trackhub\/$_/, "Contains correct resource (document) URI") } 1 .. 2;
  
  #
  # /api/trackhub/:id (GET)
  #
  ok($response = request('/api/trackhub/1'), 'GET Request to /api/trackhub/1');
  ok($response->is_success, 'Request successful 2xx');
  is($response->content_type, 'application/json', 'JSON content type');
  $content = from_json($response->content);
  is(scalar @{$content->{data}}, 1, 'One trackhub');
  is($content->{data}[0]{name}, 'bpDnaseRegionsC0010K46DNaseEBI', 'Trackhub name');
  is($content->{configuration}{bpDnaseRegionsC0010K46DNaseEBI}{bigDataUrl}, 'http://ftp.ebi.ac.uk/pub/databases/blueprint/data/homo_sapiens/Peripheral_blood/C0010K/Monocytes/DNase-Hypersensitivity//C0010K46.DNase.hotspot_v3_20130415.bb', 'Trackhub url');
  ok($response = request('/api/trackhub/3'), 'GET request to /api/trackhub/3');
  is($response->code, 404, 'Request 404');
  is($response->content_type, 'application/json', 'JSON content type');
  $content = from_json($response->content);
  like($content->{error}, qr/Could not find/, 'Correct response');

  note "Re-creating index test";
  $indexer->create_index(); # do not index this time through the indexer, the API will do that

  # now the index's empty, create the sample docs through the API
  #
  # TODO
  # /api/trackhub/create (PUT): create new document
  #
  my $docs = $indexer->docs;
  
  
}



# #
# # TODO: check status codes
# #
# # request subroutine return is HTTP::Response object with attribs:
# #  _content
# #  _rc
# #  _headers
# #  _msg
# #  _request
# #
# my $response = request('/api');
# ok( !$response->is_success, 'Request with no credentials should not succeed' );

# my $content = from_json($response->content); 
# is( $content->{data}{error}, "Please specify username/password credentials", "Error response: no credentials");

# $response = request('/api?username=pippo;password=pluto');
# ok( !$response->is_success, 'Request with incorrect credentials should not succeed' );
# $content = from_json($response->content); 
# is( $content->{data}{error}, "Unauthorized", "Unsuccessful authentication message");

# $response = request('/api?username=test;password=test');
# ok( $response->is_success, 'Request with correct credentials should succeed' );
# $content = from_json($response->content); 
# is( $content->{data}{msg}, "Welcome user test", "Successful authentication message");


# this one gets the JSON string
# $response = get '/api';
# print ref $response, "\n";

# ##########
# # Test initial gift list includes all the gifts
# #
# my @all_data = MyGifts::Model::Gifts->new->_get_data;
 
# my $response = get '/gifts';
 
# my @gifts = @{from_json($response)->{data}};
# is(@gifts, @all_data, "gift count match");
 
# for ( my $i=0 ; $i < @all_data; $i++ ) {
#   is(keys %{$gifts[$i]}, 2, "[$i] has 2 data fields");
#   is($gifts[$i]->{name}, $all_data[$i]->{name}, "[$i] name match");
#   is($gifts[$i]->{id}, $all_data[$i]->{id}, "[$i] id match");
# }

# my $response = get '/api';
# print $response;
# print Dumper(request('/api')), "\n\n";

done_testing();
