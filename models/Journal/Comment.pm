
package Journal::Comment;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table => 'comments',
  columns =>
  [
    id         => { type => 'integer', not_null => 1 },
    article_id => { type => 'integer', not_null => 1 },
    user_id    => { type => 'integer', not_null => 1 },
    epoch      => { type => 'integer', not_null => 1 },
    title      => { type => 'varchar', length => 255, not_null => 1 },
    content    => { type => 'text', not_null => 1 },
    score      => { type => 'integer', not_null => 1, default => '0' },
  ],
  pk_columns => 'id',
  foreign_keys => [ 'article', 'user' ],
);

1;

