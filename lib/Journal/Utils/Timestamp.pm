
package Journal::Utils::Timestamp;

use strict;

sub new {
  my $class = shift;
  bless { @_ }, $class;
}

sub gmtime {
  my $self = shift;

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime;
  my $ts = sprintf("%4d-%02d-%02d %02d\:%02d\:%02d", ($year+1900), ($mon+1), $mday, $hour, $min, $sec);

  return $ts;
}

1;

