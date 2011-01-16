
use strict;
use Mojolicious::Lite;
use Data::Dumper;

use lib qw(lib);
use Journal::Articles;
use Journal::DB;
use Journal::Events;
use Journal::Users;
use Journal::Utils::Timestamp;

use vars qw( $event $timer );

BEGIN {
  $event = Journal::Events->new;
  $timer = Journal::Utils::Timestamp->new;
}

# log startup
$event->logger( type => 'system', message => 'starting server');

# login form
get '/login' => sub {
  my $self = shift;
  return $self->redirect_to('index') if $self->session('username');
  $self->render;
} => 'login_form';

# login submission
post '/login' => sub {
  my $self = shift;
  # retrieve user and role info
  my $user = Journal::Users::find($self->session('username') || 'anonymous');
  if ($user->authenticates(
    username => $self->param('username'),
    password => $self->param('password'),
  ))
  {
    $self->session( username => $self->param('username') );
    $self->redirect_to('index');
  } else {
    $self->flash( message => 'Wrong username or password, please try again.' );
    $self->redirect_to('login_form');
  }
} => 'login';

# logout
get '/logout' => sub {
  my $self = shift;
  $self->session( expires => 1 );
  $self->redirect_to('login_form');
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
  $self->redirect_to('index');
} => 'article_list';

# full article view
get '/articles/:id' => sub {
  my $self = shift;
  my $article = Journal::Articles->find( id => $self->param('id') );
  if ($article) {
    $self->stash( article => $article );
    $self->render( controller => 'articles', action => 'view' );
  } else {
    $self->flash( message => 'Article not found' );
    $self->redirect_to('index');
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
  # retrieve user and role info
  my $user = Journal::Users::find($self->session('username') || 'anonymous');
  my $success = Journal::Articles->create(
    user_id => $user->{'id'},
    title => $self->param('title'),
    dept => $self->param('dept'),
    content => $self->param('content'),
  );
  $self->flash( message => 'Thank you for your submission' );
  $self->redirect_to('index');
} => 'article_submit';

app->secret('k7oiefbiwofi43o9fhaw');
app->start;

