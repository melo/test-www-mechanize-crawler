package Test::WWW::Mechanize::Crawler;

# ABSTRACT: test your sites with a WWW::Mechanize-based crawler

use strict;
use warnings;
use Test::More;
use Carp 'confess';
use URI;

sub new {
  my ($class, %args) = @_;
  my $self = bless {}, $class;

  $self->{start_url} = URI->new(delete $args{start_url})
    || confess('Invalid parameter start_url,');

  ## FIXME: create a default mechanize here?
  $self->{mech} = delete $args{mech};

  $self->{url_filter} = delete $args{url_filter}
    || \&default_link_filter;

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
  my $url_f = $self->{url_filter};

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
      my ($u, $abs) = ($l->url, $l->url_abs);
      next if $url_f->($self, $u, $abs);
      push @$queue, {url => $abs, referer => $url};
    }
  }

  return;
}

sub default_link_filter {
  my ($self, $u, $url) = @_;

  return 1 unless $u and $u ne '#';
  return 1 unless $self->uri_is_relative($url);

  return;
}

sub uri_is_relative {
  my ($self, $u) = @_;
  my $start = $self->{start_url};

  my $sscheme = $start->scheme || '';
  my $uscheme = $u->scheme     || '';
  return unless $sscheme eq $uscheme;

  my $shost = $start->host || '';
  my $uhost = $u->host     || '';
  return unless $shost eq $uhost;

  my $sport = $start->port || 80;
  my $uport = $u->port     || 80;
  return unless $sport == $uport;

  my $spath = $start->path || '/';
  my $upath = $u->path     || '/';
  return unless $upath =~ /^$spath/;

  return 1;
}


1;
