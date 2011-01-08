
package Journal::Users;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table      => 'users',
  columns    => [ qw( id role_id username password firstname lastname email url tz reputation ) ],
  pk_columns => 'id',
);

1;

