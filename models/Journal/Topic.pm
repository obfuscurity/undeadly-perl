
package Journal::Topic;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table => 'topics',
  columns =>
  [
    id          => { type => 'integer', primary_key => 1, not_null => 1 },
    name        => { type => 'varchar', length => 255, not_null => 1 },
    description => { type => 'text', not_null => 1 },
    image_url   => { type => 'varchar', length => 255 },
  ],
  pk_columns => 'id',
  unique_key => 'name',
);

1;

