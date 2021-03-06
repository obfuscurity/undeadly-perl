
package Journal::Users;

use strict;
use Data::UUID;
use DateTime::TimeZone;
use Digest::SHA;
use Email::Valid;

use Journal::DB;
use Journal::Events;
use Journal::Users::Auth;
use Journal::SMTP;
use Data::Dumper;

use vars qw( $event $timer );

BEGIN {
  $event = Journal::Events->new;
  $timer = Journal::Utils::Timestamp->new;
}

sub new {
  my $class = shift;
  my $args = shift;
  my $user = {};

  for my $key (keys %$args) {
    $user->{$key} = $args->{$key};
  }
  
  bless $user, $class;
}

sub authenticate {
  my $self = shift;
  my %args = @_;
  my $username = $args{'username'};
  my $password = $args{'password'};

  my $dbh = Journal::DB->connect;

  my $query = "SELECT u.id, u.username, u.password, u.confirmed_on FROM users u, roles r WHERE u.username=? AND r.can_login=1";
  my $sth = $dbh->prepare($query);
  $sth->execute($username) || die $dbh->errstr;
  my $result = $sth->fetchrow_hashref;

  my $valid_password = Journal::Users::Auth::validate_pass(
    plain => $password,
    hashpw => $result->{'password'}
  );

  if ( $valid_password && $result->{'confirmed_on'} ) {
    {
      my $query = "UPDATE users SET last_login_on=? WHERE username=?";
      my $sth = $dbh->prepare($query);
      $sth->execute( $timer->gmtime, $username );
    }
    $self->{'username'} = $username;
    return (1, undef);
  } elsif ( $valid_password ) {
    return (0, 'Your account has not been confirmed.');
  } else {
    return (0, 'Incorrect username or password.');
  }
}

sub find {
  my $class = shift;
  my %args = @_;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT u.id, username,
                      firstname, lastname, email, url, tz, reputation, confirmed_on,
                      manage_admins, manage_editors, manage_users,
                      edit_articles, delete_articles, create_articles, read_articles,
                      edit_comments, delete_comments, create_comments, read_comments
                FROM users u, roles r
                WHERE username=?
                AND u.role_id=r.id";
  my $sth = $dbh->prepare($query);

  $sth->execute($args{'username'}) || die $dbh->errstr;

  my $user = Journal::Users->new( $sth->fetchrow_hashref );

  if (! $user) {
    $event->logger(
      type => 'system',
      message => sprintf("user authenticated but no details found (username: %s)", $args{'username'}),
    );
  }

  return $user;
}

sub create {
  my $class = shift;
  my %args = @_;

  my $user = $class->new( \%args );

  # validate user input
  unless ($user->{'username'} =~ /[\w+]{3,12}/) {
    return (0, 'Usernames must be 3-12 letters long.');
  }
  unless ($user->{'password'} =~ /[\S+]{6,12}/) {
    return (0, 'Password must be 6-12 characters long.');
  }
  unless ($user->{'firstname'} =~ /[\w+]{1,20}/) {
    return (0, 'Firstname must be 1-20 letters long.');
  }
  unless ($user->{'lastname'} =~ /[\w+]{1,40}/) {
    return (0, 'Lastname must be 1-40 letters long.');
  }
  unless (Email::Valid->address($user->{'email'})) {
    return (0, 'Email format is invalid, please try again.');
  }
  unless ($user->{'url'} =~ /^(https?):\/\/\S+$/) {
    return (0, 'URL must be http or https, no longer than 255 characters.');
  }
  unless (DateTime::TimeZone->is_valid_name($user->{'tz'})) {
    return (0, 'Timezone must be a valid timezone name.');
  }

  my $dbh = Journal::DB->connect;

  # check for username collision
  {
    my $query = "SELECT username FROM users WHERE username=?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $user->{'username'} ) || $dbh->errstr;
    my $result = $sth->fetchrow_hashref;
    if ($result->{'username'}) {
      return (0, 'Username already exists.');
    }
  }

  my $ug = Data::UUID->new;
  $user->{'api_token'} = $ug->create_str;
  $user->{'confirm_token'} = $ug->create_str;

  # store user data
  {
    my $query = "INSERT INTO users VALUES (NULL, 4, ?,?,?,?,?,?,?, 0, ?,?, NULL, ?, NULL)";
    my $sth = $dbh->prepare($query);
    my $salt = Journal::Users::Auth::generate_salt;
    my $hashpw = Journal::Users::Auth::generate_pass( plain => $user->{'password'}, salt => $salt );
    $sth->execute(
      $user->{'username'},
      $hashpw,
      $user->{'firstname'},
      $user->{'lastname'},
      $user->{'email'},
      $user->{'url'},
      $user->{'tz'},
      $user->{'api_token'},
      $user->{'confirm_token'},
      $timer->gmtime,
    ) || die $dbh->errstr;
  }

  return ($user, undef);
}

sub send_confirmation_email {
  my $class = shift;
  my %args = @_;
  my $username = $args{'username'};
  my $url = $Journal::Config::url;

  my $dbh = Journal::DB->connect;
  my $query = "SELECT firstname, lastname, email, confirm_token FROM users WHERE username=?";
  my $sth = $dbh->prepare($query);
  $sth->execute($username) || die $dbh->errstr;
  my $result = $sth->fetchrow_hashref;

  my $smtp = Journal::SMTP->new;
  my ($delivery, $error) = $smtp->send(
    route => 'local',
    sender => 'signup@undeadly.org',
    recipient => $result->{'email'},
    from => 'OpenBSD Journal <signup@undeadly.org>',
    to => sprintf("%s %s <%s>", $result->{'firstname'}, $result->{'lastname'}, $result->{'email'}),
    subject => 'OpenBSD Journal Confirmation',
    body => , 'Hello ' . $result->{'firstname'} . ",\n\n" .
      "Click the following link to complete your registration\n" .
      "and begin using your OpenBSD Journal user account.\n\n" .
      $url . '/users/' . $username . '/confirm/' . $result->{'confirm_token'} . "\n\n" .
      "If you have any questions please reply to this email.\n\n" .
      "Thanks,\n\n--\nOpenBSD Journal\nhttp://undeadly.org/",
  );

  if ($delivery) {
    return (1, undef);
  } else {
    return (0, $error);
  }
}

sub confirm_email {
  my $class = shift;
  my %args = @_;
  my $username = $args{'username'};
  my $confirm_token = $args{'confirm_token'};

  my $dbh = Journal::DB->connect;
  my $query = "UPDATE users SET confirmed_on=? WHERE username=? AND confirm_token=?";
  my $sth = $dbh->prepare($query);
  $sth->execute( $timer->gmtime, $username, $confirm_token ) || die $dbh->errstr;

  if ($sth->rows == 1) {
    return (1, undef);
  } else {
    return (0, 'We were unable to confirm your email. Please try your confirmation link again, request a new confirmation link below, or contact our support team for assistance.');
  }
}

1;

