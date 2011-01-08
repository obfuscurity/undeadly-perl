
package Journal::Roles;

use strict;
use base qw(Journal::DB::Object);

__PACKAGE__->meta->setup(
  table      => 'roles',
  columns    => [ qw( id name manage_admins manage_editors manage_users
                      edit_articles delete_articles create_articles read_articles
                      edit_comments delete_comments create_comments read_comments ) ],
  pk_columns => 'id',
  unique_key => 'name',
);

1;

