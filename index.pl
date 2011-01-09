
use strict;
use Mojolicious::Lite;
use Data::Dumper;

use lib './models';
use Journal::Articles;
use Journal::Users;
use Journal::Roles;
use Journal::Events;

# retrieve user and role info
my $user = Journal::Users->find_by_username($self->session('username') || 'anonymous');
my $user->{'permissions'} = Journal::Roles->find_by_user_id($user->{'id'});

# events object for logging
my $logger = Journal::Events->new;

# login form
get '/login' => sub {
  my $self = shift;
  return $self->redirect_to('index') if $self->session('username');
  $self->render;
} => 'login';

# login submission
post '/login' => sub {
  my $self = shift;
  my $success;
  {
    my $query = "SELECT count(*) AS count FROM users WHERE username=? AND password=SHA1(?)";
    my $sth = $dbh->prepare($query);
    $sth->execute($self->param('username'), $self->param('password')) || die $dbh->errstr;
    $success = $sth->fetchrow_hashref->{'count'};
  }
  if ($success) {
    my $query = "UPDATE users SET last_login_on=NOW() WHERE username=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($self->param('username')) || die $dbh->errstr;
    $self->session( username => $self->param('username') );
    $self->redirect_to('index');
  } else {
    $self->flash( message => 'Wrong username or password, please try again.' );
    $self->redirect_to('login');
  }
} => 'login';

# logout
get '/logout' => sub {
  my $self = shift;
  $self->session( expires => 1 );
  $self->redirect_to('login');
} => 'logout';

# front page
get '/' => sub {
  my $self = shift;
  my $articles = Journal::Articles->find({
    status => 'published',
    limit => ($self->param('limit') || 10),
  });
  $self->stash( articles => $articles );
  $self->render( controller => 'articles, action => 'list' );
} => 'index';

# article list, redirect to index
get '/articles' => sub {
  my $self = shift;
  $self->redirect_to('index');
} => 'article_list';

# full article view
get '/articles/:id' => sub {
  my $self = shift;
  my $article = Journal::Articles->find({
    status => 'published',
    id => $self->param('id'),
  });
  $self->stash( article => $article );
  $self->render( controller => 'articles', action => 'view' );
} => 'article_view';

# article form
get '/articles/add' => sub {
  my $self = shift;
  $self->render( controller => 'articles', action => 'add' );
} => 'article_add';

# article submission
post '/articles/add' => sub {
  my $self = shift;
  my $article = Journal::Articles->create({
    topic_id => 1,
    status => 'submission',
    user_id => $user->{'id'},
    title => $self->param('title'),
    dept => $self->param('dept'),
    content => $self->param('content'),
    description => sprintf("Initial submission from %s.", $user->{'username'}),
    format => 'html',
  });
  $self->flash( message => 'Thank you for your submission' );
  $self->redirect_to('index');
} => 'article_submit';


