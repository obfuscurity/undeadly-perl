
package Journal::User;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table => 'users',
  columns =>
  [
    id         => { type => 'integer', not_null => 1 },
    role_id    => { type => 'integer', not_null => 1 },
    username   => { type => 'varchar', length => 255, not_null => 1 },
    password   => { type => 'varchar', length => 255, not_null => 1 },
    firstname  => { type => 'varchar', length => 255, not_null => 1 },
    lastname   => { type => 'varchar', length => 255, not_null => 1 },
    email      => { type => 'varchar', length => 255, not_null => 1 },
    url        => { type => 'varchar', length => 255, not_null => 1 },
    tz         => { type => 'varchar', length => 255, not_null => 1 },
    reputation => { type => 'integer', not_null => 1, default => '0' },
  ],
  pk_columns => 'id',
  foreign_keys => [ 'role' ],
);

1;

