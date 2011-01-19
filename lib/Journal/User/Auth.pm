
package Journal::User::Auth;

use strict;
use Digest::SHA;
use MIME::Base64;

#my $hashpw = generate_pass( plain => 'foobar', salt => _generate_salt() );
#print "$hashpw\n";
#my $salt = _extract_salt($hashpw);
#my $testpw = generate_pass( plain => 'foobar', salt => $salt );
#print "$testpw\n";

sub generate_pass {
  my %args = @_;
  my $plain = $args{'plain'};
  my $salt = $args{'salt'} || _generate_salt();

  return MIME::Base64::encode( Digest::SHA::sha256( $plain . $salt ) . $salt, '' );
}

sub validate_pass {
  my %args = @_;
  my $plain = $args{'plain'};
  my $hashpw = $args{'hashpw'};

  my $salt = _extract_salt($hashpw);
  if ( generate_pass($plain, $salt) eq $hashpw ) {
    return 1;
  } else {
    return 0;
  }
}
 
sub _generate_salt {
  my @bytes;
  my $len = 8 + int(rand(8));
  for my $i (1 .. $len) {
    push(@bytes, rand(255));
  }
  return pack('C*', @bytes);
}

sub _extract_salt {
  my $hashpw = shift;
  my $hashlen = 32; # sha256
  $hashpw = MIME::Base64::decode($hashpw);
  my @tmp = unpack('C*', $hashpw);
  my $i = 0;
  my @hash;
  while ( $i < $hashlen ) {
    push(@hash, shift(@tmp));
    $i++;
  }
  my @salt;
  for my $element (@tmp) {
    push(@salt, $element);
  }
  my $salt = pack( 'C*', @salt );
  return $salt;
}

1;

