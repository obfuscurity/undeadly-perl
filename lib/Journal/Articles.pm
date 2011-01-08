
package Journal::Articles;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table      => 'articles',
  columns    => [ qw( id revision_id topic_id status ) ],
  pk_columns => 'id',
);

1;

