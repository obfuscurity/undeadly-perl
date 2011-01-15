
package Journal::DB;

use strict;
use DBI;
use Journal::Config;

use vars qw( $dbh $is_connected );

BEGIN { $is_connected = 0; }

sub connect {
  my $self = shift;
  my %args = @_;

  if ( $is_connected && $dbh->ping ) {
    return $dbh;
  }

  if ($is_connected) {
    $dbh->disconnect;
    $is_connected = 0;
  }

  $dbh = DBI->connect(Journal::Config::dsn);

  return $dbh;
}

1;

