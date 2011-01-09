
package Journal::Event;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->make_manager_class('events');
__PACKAGE__->meta->setup(
  table => 'events',
  columns =>
  [
    id      => { type => 'integer', not_null => 1 },
    type    => { type => 'varchar', length => 255, not_null => 1 },
    message => { type => 'text', not_null => 1 },
  ],
  pk_columns => 'id',
);

1;

