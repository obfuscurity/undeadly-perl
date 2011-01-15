
package Journal::Article;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->make_manager_class('articles');
__PACKAGE__->meta->error_mode('carp');
__PACKAGE__->meta->setup(
  table  => 'articles',
  columns =>
  [
    id          => { type => 'integer', primary_key => 1, not_null => 1 },
    revision_id => { type => 'integer', not_null => 1 },
    topic_id    => { type => 'integer', not_null => 1 },
    status      => { type => 'varchar', length => 255, not_null => 1 },
  ],
  pk_columns => 'id',
  foreign_keys => [ 'revision', 'topic' ],
);

1;

