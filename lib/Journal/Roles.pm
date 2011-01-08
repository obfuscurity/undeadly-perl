
package Journal::Roles;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table => 'roles',
  columns =>
  [
    id => { type => 'integer', not_null => 1 },
    name => { type => 'text', not_null => 1 },
    manage_admins => { type => 'boolean', not_null => 1, default => '0' },
    manage_editors => { type => 'boolean', not_null => 1, default => '0' },
    manage_users => { type => 'boolean', not_null => 1, default => '0' },
    edit_articles => { type => 'boolean', not_null => 1, default => '0' },
    delete_articles => { type => 'boolean', not_null => 1, default => '0' },
    create_articles => { type => 'boolean', not_null => 1, default => '0' },
    read_articles => { type => 'boolean', not_null => 1, default => '1' },
    edit_comments => { type => 'boolean', not_null => 1, default => '0' },
    delete_comments => { type => 'boolean', not_null => 1, default => '0' },
    create_comments => { type => 'boolean', not_null => 1, default => '0' },
    read_comments => { type => 'boolean', not_null => 1, default => '1' },
  ],
  pk_columns => 'id',
  unique_key => 'name',
);

1;

