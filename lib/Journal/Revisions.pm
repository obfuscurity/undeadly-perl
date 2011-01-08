
package Journal::Revisions;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table => 'revisions',
  columns =>
  [
    id          => { type => 'integer', not_null => 1 },
    article_id  => { type => 'integer', not_null => 1 },
    user_id     => { type => 'integer', not_null => 1 },
    epoch       => { type => 'integer', not_null => 1 },
    title       => { type => 'text', not_null => 1 },
    dept        => { type => 'text', not_null => 1 },
    content     => { type => 'text', not_null => 1 },
    description => { type => 'text', not_null => 1 },
    format      => { type => 'varchar', length => 255, not_null => 1 },
    old_sid     => { type => 'integer' },
  ],
  pk_columns => 'id',
  foreign_keys => [ 'article', 'user' ],
);

1;

