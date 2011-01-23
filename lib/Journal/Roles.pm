
package Journal::Roles;

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

  unless ($name) {
    return (0, 'Need a valid name for this role.');
  }

  my $dbh = Journal::DB::connect;
  my $role_exists;
  {
    my $query = "SELECT count(*) FROM roles WHERE name=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($name) || die $dbh->errstr;
    my $result = $sth->fetchrow_hashref;
    $role_exists = $result->{'count'} || undef;
  }

  if ($role_exists) {
    return (0, 'Please choose another name, this role already exists.');
  } else {
    my $query = "INSERT INTO roles VALUES (NULL, ?, 0,0,0,0,0,0,1,0,0,0,1,0)";
    my $sth = $dbh->prepare($query);
    $sth->execute($name) || die $dbh->errstr;
    return (1, undef);
  }
}

sub find_all {
  my $class = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT * FROM roles";
  my $sth = $dbh->prepare($query);
  $sth->execute || die $dbh->errstr;

  my @roles;
  while (my $result = $sth->fetchrow_hashref) {
    push(@roles, $result);
  }

  return \@roles;
}

sub find {
  my $class = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT * FROM roles WHERE id=?";
  my $sth = $dbh->prepare($query);
  $sth->execute($args{'id'}) || die $dbh->errstr;

  my $role = $sth->fetchrow_hashref;

  return $role || 0;
}

sub destroy {
  my $class = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $role_in_use;
  {
    my $query = "SELECT count(*) FROM users u, roles r
                 WHERE u.role_id=r.id
                 AND r.id=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($args{'id'}) || die $dbh->errstr;
    my $result = $sth->fetchrow_hashref;
    $role_in_use = ($result->{'count'} > 0) ? 1 : undef;
  }

  if ($role_in_use) {
    return (0, 'Role is in use, unable to destroy at this time.');
  } else {
    my $query = "DELETE FROM roles WHERE id=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($args{'id'}) || die $dbh->errstr;
    return (1, undef);
  }
}

1;

