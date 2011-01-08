
package Journal::Topics;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table => 'topics',
  columns =>
  [
    id          => { type => 'integer', not_null => 1 },
    name        => { type => 'text', not_null => 1 },
    description => { type => 'text', not_null => 1 },
    image_url   => { type => 'text' },
  ],
  pk_columns => 'id',
  unique_key => 'name',
);

1;

