
package Journal::Topics;

use strict;
use Journal::DB;
use Journal::Events;
use Journal::Utils::Timestamp;
use Data::Dumper;

use vars qw( $event $timer );

BEGIN {
  $event = Journal::Events->new;
  $timer = Journal::Utils::Timestamp->new;
}

sub new {
  my $class = shift;
  bless { @_ }, $class;
}

sub create {
  my $self = shift;
  my %args = @_;
  my $name = $args{'name'};
  my $description = $args{'description'};
  my $image_url = $args{'image_url'} || '';

  unless ($name && $description) {
    return (0, 'Need a valid name and description for this topic.');
  }

  my $dbh = Journal::DB::connect;
  my $topic_exists;
  {
    my $query = "SELECT count(*) FROM topics WHERE name=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($name) || die $dbh->errstr;
    my $result = $sth->fetchrow_hashref;
    $topic_exists = $result->{'count'} || undef;
  }

  if ($topic_exists) {
    return (0, 'Please choose another name, this topic already exists.');
  } else {
    my $query = "INSERT INTO topics VALUES (NULL, ?,?,?)";
    my $sth = $dbh->prepare($query);
    $sth->execute($name, $description, $image_url) || die $dbh->errstr;
    return (1, undef);
  }
}

sub find_all {
  my $class = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT * FROM topics";
  my $sth = $dbh->prepare($query);
  $sth->execute || die $dbh->errstr;

  my @topics;
  while (my $result = $sth->fetchrow_hashref) {
    push(@topics, $result);
  }

  return \@topics;
}

sub find {
  my $class = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT * FROM topics WHERE id=?";
  my $sth = $dbh->prepare($query);
  $sth->execute($args{'id'}) || die $dbh->errstr;

  my $topic = $sth->fetchrow_hashref;

  return $topic || 0;
}

sub destroy {
  my $class = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $topic_in_use;
  {
    my $query = "SELECT count(*) FROM articles a, topics t
                 WHERE a.topic_id=t.id
                 AND t.id=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($args{'id'}) || die $dbh->errstr;
    my $result = $sth->fetchrow_hashref;
    $topic_in_use = ($result->{'count'} > 0) ? 1 : undef;
  }

  if ($topic_in_use) {
    return (0, 'Topic is in use, unable to destroy at this time.');
  } else {
    my $query = "DELETE FROM topics WHERE id=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($args{'id'}) || die $dbh->errstr;
    return (1, undef);
  }
}

1;

