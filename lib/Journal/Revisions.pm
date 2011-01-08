
package Journal::Revisions;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table      => 'revisions',
  columns    => [ qw( id article_id user_id epoch title dept content description format old_sid ) ],
  pk_columns => 'id',
);

1;

