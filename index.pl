
use strict;
use Mojolicious::Lite;
use Data::Dumper;

use lib qw(lib);
use Journal::Articles;
use Journal::DB;
use Journal::Events;
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
});

# login form
get '/login' => sub {
  my $self = shift;
  return $self->redirect_to('index') if $self->session('username');
  $self->render;
} => 'login';

# login submission
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
  return $self->redirect_to('index') unless $self->session('username');
  $self->session( expires => 1 );
  return $self->redirect_to('login');
} => 'logout';

# front page
get '/' => sub {
  my $self = shift;
  my $articles = Journal::Articles->find_all( status => 'submitted' );
  $self->stash( articles => $articles );
  $self->flash( message => 'No articles found' ) unless (@$articles);
  $self->render( controller => 'articles', action => 'list' );
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
  $self->render( controller => 'articles', action => 'add' );
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
get '/user/add' => sub {
  my $self = shift;
  if ($self->session('username')) {
    $self->flash( message => sprintf("You are already logged in as %s.", $self->session('username')) );
    return $self->redirect_to('index');
  }
  return $self->render( controller => 'user', action => 'add' );
} => 'user_add';

# user add submission
post '/user/add' => sub {
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
    return $self->redirect_to('confirm_email');
  } else {
    $self->flash( message => $error );
    return $self->redirect_to('user_add');
  }
};

# confirmation post
post '/user/:id/confirm/:token' => ([id => qr/\w+/]) => sub {
  my $self = shift;
  my ($success, $error) = $user->confirm_email(
    username => $self->param('id'),
    confirm_token => $self->param('token'),
  );
  if ($success) {
    $self->flash( message => 'Your email has been confirmed.' );
    return $self->redirect_to('index');
  } else {
    $self->flash( message => $error );
    return $self->redirect_to('confirm_email');
  }
};

# confirmation request page
get '/user/:id/confirm' => ([id => qr/\w+/]) => sub {
  my $self = shift;
  if ( $self->session('username') && $user->{'confirmed_on'} ) {
    $self->flash( message => 'Your email has already been confirmed.' );
    return $self->redirect_to('index');
  }
  return $self->render( controller => 'user', action => 'confirm' );
} => 'confirm_email';

# confirmation request submission
post '/user/:id/confirm' => ([id => qr/\w+/]) => sub {
  my $self = shift;
  my ($delivery, $error) = $user->send_confirmation_email;
  if ($delivery) {
    $self->flash( message => 'Please check your inbox for a confirmation email.' );
    return $self->redirect_to('index');
  } else {
    $self->flash( message => $error );
    return $self->redirect_to('index');
  }
};

app->secret('k7oiefbiwofi43o9fhaw');
app->start;

