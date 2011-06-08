#!perl

use strict;
use warnings;
use Test::More;
use Test::Fatal;

use_ok('Test::WWW::Mechanize::Crawler');

my $crawler;
is(
  exception {
    $crawler = Test::WWW::Mechanize::Crawler->new(start_url => '/');
  },
  undef,
  'new() lives without mech parameter',
);

done_testing();
