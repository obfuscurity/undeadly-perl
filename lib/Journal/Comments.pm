
package Journal::Comments;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table      => 'comments',
  columns    => [ qw( id article_id user_id epoch title content score ) ],
  pk_columns => 'id',
);

1;

