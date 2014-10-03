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
use Catalyst::Test 'ElasticSearchDemo';
use ElasticSearchDemo::Controller::API;

my $response = request('/api/list');
print Dumper($response);

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
