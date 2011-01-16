
package Journal::Articles;

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

  my $dbh = Journal::DB::connect;
  {
    my $query = "INSERT INTO revisions VALUES (NULL, 0, ?,?,?,?,?,?,?, NULL)";
    my $sth = $dbh->prepare($query);
    $sth->execute(
      $args{'user_id'},
      $timer->gmtime,
      $args{'title'},
      $args{'dept'},
      $args{'content'},
      'initial submission',
      'html',
    ) || die $dbh->errstr;
  }
  my $revision_id = $dbh->last_insert_id;
  {
    my $query = "INSERT INTO articles VALUES (NULL, ?,?,?, NULL)";
    my $sth = $dbh->prepare($query);
    $sth->execute( $revision_id, 1, 'submitted' ) || die $dbh->errstr;
  }
  my $article_id = $dbh->last_insert_id;
  {
    my $query = "UPDATE revisions SET article_id=? WHERE id=?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $article_id, $revision_id ) || die $dbh->errstr;
  }

  return 1;
}

sub find_all {
  my $self = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT a.id, a.published_on,
                      r.timestamp, r.title, r.dept, r.content, r.description, r.format,
                      t.name, t.description AS topic_description, t.image_url, u.username
                FROM articles a, revisions r, topics t, users u
                WHERE a.status=?
                AND a.revision_id=r.id
                AND a.topic_id=t.id
                AND r.user_id=u.id
                ORDER BY a.published_on DESC
                LIMIT ?";
  my $sth = $dbh->prepare($query);

  $sth->execute(
    ($args{'status'} || 'published'),
    ($args{'limit'} || 10),
  ) || die $dbh->errstr;

  my @articles;
  while (my $result = $sth->fetchrow_hashref) {
    push(@articles, $result);
  }

  return \@articles;
}

sub find {
  my $self = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT a.id, a.status, a.published_on,
                      r.timestamp, r.title, r.dept, r.content, r.description, r.format,
                      t.name, t.description AS topic_description, t.image_url, u.username
                FROM articles a, revisions r, topics t, users u
                WHERE a.id=?
                AND a.revision_id=r.id
                AND a.topic_id=t.id
                AND r.user_id=u.id";
  my $sth = $dbh->prepare($query);

  $sth->execute($args{'id'}) || die $dbh->errstr;

  my $article = $sth->fetchrow_hashref;

  return $article || 0;
}

1;

