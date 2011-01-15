
package Journal::Users;

use strict;
use Journal::DB;
use Journal::Events;

use vars qw( $event );

BEGIN {
  $event = Journal::Events->new;
}

sub new {
  my $class = shift;
  bless { @_ }, $class;
}

sub authenticates {
  my $self = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT id, username FROM users WHERE username=? AND password=?";
  my $sth = $dbh->prepare($query);

  $sth->execute(
    $args{'username'},
    $args{'password'},
  ) || die $dbh->errstr;

  if ($sth->rows > 1) {
    $event->logger(
      type => 'system',
      message => sprintf("duplicate credentials found (user: %s)", $args{'username'}),
    );
  }

  my $user = $sth->fetchrow_hashref;

  return $user;
}

sub find {
  my $self = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT u.id, username,
                      firstname, lastname, email, url, tz, reputation,
                      manage_admins, manage_editors, manage_users,
                      edit_articles, delete_articles, create_articles, read_articles,
                      edit_comments, delete_comments, create_comments, read_comments
                FROM users u, roles r
                WHERE username=?
                AND u.role_id=r.id";
  my $sth = $dbh->prepare($query);

  $sth->execute($args{'username'}) || die $dbh->errstr;

  my $user = $sth->fetchrow_hashref;

  if (! $user) {
    $event->logger(
      type => 'system',
      message => sprintf("user authenticated but no details found (username: %s)", $args{'username'}),
    );
  }

  return $user;
}

1;

