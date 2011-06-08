package Test::WWW::Mechanize::Crawler;

# ABSTRACT: test your sites with a WWW::Mechanize-based crawler

use strict;
use warnings;
use Test::More;
use Carp 'confess';
use URI;

sub new {
  my ($class, %args) = @_;
  my $self = {};

  $self->{start_url} = URI->new(delete $args{start_url})
    || confess('Invalid parameter start_url,');

  ## FIXME: create a default mechanize here?
  $self->{mech} = delete $args{mech};

  $self = bless $self, $class;
  $self->reset;

  return $self;
}

sub reset {
  my $self = shift;

  $self->{queue} =
    [{url => $self->{start_url}, referer => '** start_url **'}];
  $self->{seen} = {};

  return;
}

sub crawler {
  my $self = shift;
  my $mech = $self->{mech};

  my $seen  = $self->{seen};
  my $queue = $self->{queue};

  while (@$queue) {
    my $item = shift @$queue;
    my $url  = $item->{url};
    my $ref  = $item->{referer};

    next if $seen->{$url}++;

    if (!$mech->get_ok($url)) {
      fail("Failed URL '$url' (referer $ref), " . $mech->content);
      next;
    }

    for my $l ($mech->links) {
      my $u = $l->url;
      next unless $u and $u ne '#';
      push @$queue, {url => $u, referer => $url};
    }
  }

  return;
}


1;
