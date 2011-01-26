
use strict;
use Mojolicious::Lite;
use Data::Dumper;

use lib qw(lib);
use Journal::Articles;
use Journal::DB;
use Journal::Events;
use Journal::Roles;
use Journal::Topics;
use Journal::Users;

use vars qw( $event $user );

BEGIN {
  $event = Journal::Events->new;
  $event->logger( type => 'system', message => 'starting server');
}

# get user details, if possible
app->hook(after_static_dispatch => sub {
  my $self = shift;
  $user = Journal::Users->find( username => ($self->session('username') || 'anonymous') );
  $self->stash( user => $user );
});

# login
post '/login' => sub {
  my $self = shift;
  my ($valid_password, $error) = $user->authenticate(
    username => $self->param('username'),
    password => $self->param('password'),
  );
  if ($valid_password) {
    $self->session( username => $user->{'username'} );
    return $self->redirect_to('index');
  } else {
    $self->flash( message => $error );
    return $self->redirect_to('login');
  }
};

# logout
get '/logout' => sub {
  my $self = shift;
  return $self->redirect_to('index') if ($user->{'username'} eq 'anonymous');
  $self->session( expires => 1 );
  return $self->redirect_to('index');
} => 'logout';

# front page
get '/' => sub {
  my $self = shift;
  my $articles = Journal::Articles->find_all( status => 'submitted' );
  $self->stash( articles => $articles );
  $self->flash( message => 'No articles found' ) unless (@$articles);
  return $self->render( controller => 'articles', action => 'list' );
} => 'index';

# article list, redirect to index
get '/articles' => sub {
  my $self = shift;
  return $self->redirect_to('index');
};

# full article view
get '/articles/:id' => ([id => qr/\d+/]) => sub {
  my $self = shift;
  my $article = Journal::Articles->find( id => $self->param('id') );
  if ($article) {
    $self->stash( article => $article );
    return $self->render( controller => 'articles', action => 'view' );
  } else {
    $self->flash( message => 'Article not found' );
    return $self->redirect_to('index');
  }
} => 'article_view';

# article form
get '/articles/add' => sub {
  my $self = shift;
  return $self->render( controller => 'articles', action => 'add' );
} => 'article_add';

# article submission
post '/articles/add' => sub {
  my $self = shift;
  my $success = Journal::Articles->create(
    user_id => $user->{'id'},
    title => $self->param('title'),
    dept => $self->param('dept'),
    content => $self->param('content'),
  );
  $self->flash( message => 'Thank you for your submission' );
  return $self->redirect_to('index');
};

# user add form
get '/users/add' => sub {
  my $self = shift;
  unless ($user->{'username'} eq 'anonymous') {
    $self->flash( message => sprintf("You are already logged in as %s.", $user->{'username'}) );
    return $self->redirect_to('index');
  }
  return $self->render( controller => 'users', action => 'add' );
} => 'user_add';

# user add submission
post '/users/add' => sub {
  my $self = shift;
  my ($user, $error) = Journal::Users->create(
    username => $self->param('username'),
    password1 => $self->param('password1'),
    password2 => $self->param('password2'),
    firstname => $self->param('firstname'),
    lastname => $self->param('lastname'),
    email => $self->param('email'),
    url => $self->param('url'),
    tz => $self->param('tz'),
  );
  if ($user) {
    my ($delivery, $error) = Journal::Users->send_confirmation_email( username => $self->param('username') );
    if ($delivery) {
      $self->flash( message => 'Please check your inbox for a confirmation email.' );
      return $self->redirect_to('index');
    } else {
      $self->flash( message => $error );
      return $self->redirect_to('user_confirm');
    }
  } else {
    $self->flash( message => $error );
    return $self->redirect_to('user_add');
  }
};

# email confirmation
get '/users/:id/confirm/:token' => ([id => qr/\w+/]) => sub {
  my $self = shift;
  my ($success, $error) = Journal::Users->confirm_email(
    username => $self->param('id'),
    confirm_token => $self->param('token'),
  );
  if ($success) {
    $self->flash( message => 'Your email has been confirmed. You may now login.' );
    return $self->redirect_to('index');
  } else {
    $self->flash( message => $error );
    return $self->redirect_to('user_confirm');
  }
};

# email confirmation resend form
get '/users/confirm' => ([id => qr/\w+/]) => sub {
  my $self = shift;
  if ( ($user->{'username'} ne 'anonymous') && $user->{'confirmed_on'} ) {
    $self->flash( message => 'Your email has already been confirmed.' );
    return $self->redirect_to('index');
  }
  return $self->render( controller => 'users', action => 'confirm' );
} => 'user_confirm';

# email confirmation resend submission
post '/users/confirm' => ([id => qr/\w+/]) => sub {
  my $self = shift;
  my ($delivery, $error) = Journal::Users->send_confirmation_email( username => $self->param('username') );
  if ($delivery) {
    $self->flash( message => 'Confirmation resent. Please check your inbox for the confirmation link.' );
    return $self->redirect_to('index');
  } else {
    $self->flash( message => $error );
    return $self->redirect_to('user_confirm');
  }
};

# user profile
get '/users/:id' => ([id => qr/\w+/]) => sub {
  my $self = shift;
  my $profile;
  if ( $user->{'username'} eq $self->param('id') ) {
    $profile = $user;
  } else {
    $profile = Journal::Users->find( username => $self->param('id') );
  }
  $self->stash( profile => $profile );
  return $self->render( controller => 'users', action => 'profile' );
} => 'user_profile';

# manage roles
get '/roles' => sub {
  my $self = shift;
  my $roles = Journal::Roles->find_all;
  if ($user->{'manage_users'}) {
    $self->stash( roles => $roles );
    $self->flash( message => 'No roles found' ) unless (@$roles);
    return $self->render( controller => 'roles', action => 'list' );
  } else {
    $self->flash( message => 'You be lost, biotch. Step off.');
    return $self->redirect_to('not_found');
  }
} => 'roles_list';

# manage topics
get '/topics' => sub {
  my $self = shift;
  my $topics = Journal::Topics->find_all;
  if ($user->{'edit_articles'}) {
    $self->stash( topics => $topics );
    $self->flash( message => 'No topics found' ) unless (@$topics);
    return $self->render( controller => 'topics', action => 'list' );
  } else {
    $self->flash( message => 'You be lost, biotch. Step off.');
    return $self->redirect_to('not_found');
  }
} => 'topics_list';

# 404 page not found
get '/404' => sub {
  my $self = shift;
  return $self->render( status => 404, action => 'not_found' );
} => 'not_found';

app->secret('k7oiefbiwofi43o9fhaw');
app->start;

