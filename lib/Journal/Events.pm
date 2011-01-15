
package Journal::Events;

use strict;
use Journal::DB;

sub new {
  my $class = shift;
  bless { @_ }, $class;
}

sub logger {
  my $self = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $stmt = "INSERT INTO events VALUES (NULL, datetime('now'), ?,?)";
  my $sth = $dbh->prepare($stmt);

  $sth->execute(
    $args{'type'},
    $args{'message'},
  ) || die $dbh->errstr;

  return;
}

1;

