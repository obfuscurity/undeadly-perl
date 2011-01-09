
package Journal::DB;

use strict;
use Rose::DB;
our @ISA = qw(Rose::DB);

# Use a private registry for this class
__PACKAGE__->use_private_registry;

# Register our data source
__PACKAGE__->register_db(
  driver => 'sqlite',
  database => './db/production.sqlite'
);

1;

