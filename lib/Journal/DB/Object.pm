
package Journal::DB::Object;

use strict;
use Journal::DB;
use base qw(Rose::DB::Object);

sub init_db { Journal::DB->new }

1;
