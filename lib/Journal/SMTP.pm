
package Journal::SMTP;

use strict;
use HTTP::Request;
use JSON::Any;
use LWP::UserAgent;
use Net::SMTP;

use Journal::DB;
use Journal::Events;
use Data::Dumper;

use vars qw( $event );

BEGIN {
  $event = Journal::Events->new;
}

sub new {
  my $class = shift;
  bless { @_ }, $class;
}

sub send {
  my $self = shift;
  my %args = @_;

  if ($args{'route'} eq 'postmark') {
    return $self->_send_postmark(%args);
  } elsif ($args{'route'} eq 'local') {
    return $self->_send_local(%args);
  } else {
    $event->logger(
      type => 'system',
      message => sprintf("Unknown SMTP delivery method: %s", $args{'route'}),
    );
    return (0, 'Email delivery failure. Please contact OpenBSD Journal support.');
  }
}

sub _send_postmark {
  my $self = shift;
  my %args = @_;
  my $from = $args{'sender'};
  my $to = $args{'recipient'};
  my $subject = $args{'subject'};
  my $body = $args{'body'};
  my $postmark_token = $Journal::Config::postmark_token;

  my $message = {
    From => $from,
    To => $to,
    Subject => $subject,
    TextBody => $body,
  };

  my $json = JSON::Any->new;
  my $ua = LWP::UserAgent->new( timeout => 30 );
  my $req = HTTP::Request->new(
    'post',
    'http://api.postmarkapp.com/email',
    [
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'X-Postmark-Server-Token' => $postmark_token,
    ],
    $json->to_json($message),
  );
  my $resp = $ua->request($req);

  if ($resp->is_success) {
    return (1, undef);
  } else {
    $event->logger(
      type => 'system',
      message => sprintf("Unable to send confirmation email: %s", $resp->status_line),
    );
    return (0, 'We encountered a problem sending out your Email confirmation. Please wait a few minutes and use the form below to resend your confirmation.');
  }
}

sub _send_local {
  my $self = shift;
  my %args = @_;
  my $sender = $args{'sender'};
  my $recipient = $args{'recipient'};
  my $from = $args{'from'};
  my $to = $args{'to'};
  my $subject = $args{'subject'};
  my $body = $args{'body'};

  eval {
    my $smtp = Net::SMTP->new('localhost');
    $smtp->mail($sender);
    $smtp->to($recipient);
    $smtp->data();
    $smtp->datasend("From: $from\n");
    $smtp->datasend("To: $to\n");
    $smtp->datasend("Subject: $subject\n\n");
    $smtp->datasend($body);
    $smtp->dataend();
    $smtp->quit;
  };

  unless ($@) {
    return (1, undef);
  } else {
    $event->logger(
      type => 'system',
      message => sprintf("Unable to send confirmation email: %s", $@),
    );
    return (0, 'We encountered a problem sending out your Email confirmation. Please wait a few minutes and use the form below to resend your confirmation.');
  }
}

1;

