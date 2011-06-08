#!perl

use strict;
use warnings;
use Test::More;
use Test::Fatal;

use_ok('Test::WWW::Mechanize::Crawler');
my $class = 'Test::WWW::Mechanize::Crawler';


is(
  exception { $class->new(start_url => 'http://example.com/') },
  undef, 'new() ok with start_url as full URL',
);
is(
  exception { $class->new(start_url => '/') },
  undef, 'new() ok with start_url as relative URL',
);

like(
  exception { $class->new },
  qr{^Invalid parameter start_url, },
  'new() dies properly without start_url',
);

done_testing();
