
package Journal::Events;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table      => 'events',
  columns    => [ qw( id type message ) ],
  pk_columns => 'id',
);

1;

