package Test::WWW::Mechanize::Crawler;

# ABSTRACT: test your sites with a WWW::Mechanize-based crawler

use strict;
use warnings;
use Test::More;
use Exporter;

our @ISA    = qw( Exporter );
our @EXPORT = qw( crawler );

sub new {
  my ($class, %args) = @_;
  my $self = bless \%args, $class;

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
    ok($mech->is_html, "... and it looks like HTML");

    for my $l ($mech->links) {
      next unless $l->tag eq 'a' or $l->tag eq 'img';

      my $u = $l->url;
      ok($u, "... link found is not empty ($u)");
      isnt($u, '#', "...... and not '#' ($u)");

      push @$queue, {url => $u, referer => $url};
    }
  }

  return;
}


1;
