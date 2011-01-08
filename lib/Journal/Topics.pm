
package Journal::Topics;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table      => 'topics',
  columns    => [ qw( id name description image_url ) ],
  pk_columns => 'id',
  unique_key => 'name',
);

1;

