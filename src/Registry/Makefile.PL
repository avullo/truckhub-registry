#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Registry';
all_from 'lib/Registry.pm';

requires 'Catalyst::Runtime' => '5.90071';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';

# for authentication/session handlng, as per
# http://www.catalystframework.org/calendar/2007/5
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Authentication::Credential::HTTP';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::StatusMessage';
requires 'CatalystX::SimpleLogin';
requires 'Catalyst::Controller::ActionRole';
requires 'Catalyst::ActionRole::ACL';

requires 'Moose';
requires 'MooseX::NonMoose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

# for handling profile and registration forms
requires 'HTML::FormHandler::Moose';

requires 'List::Util';
requires 'String::Random';
requires 'Search::Elasticsearch';

requires 'Compress::Zlib';
requires 'Compress::Bzip2';
requires 'IO::Uncompress::Bunzip2';

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;