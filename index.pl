
use strict;
use Mojolicious::Lite;
use Data::Dumper;

use lib 'models';
use Journal::Article;
use Journal::User;
use Journal::Role;
use Journal::Event;

# retrieve user and role info
#my $user = Journal::User->find_by_username($self->session('username') || 'anonymous');
#my $user->{'permissions'} = Journal::Role->find_by_user_id($user->{'id'});

# log startup
logger( type => 'system', message => 'starting server' );

# login form
get '/login' => sub {
  my $self = shift;
  return $self->redirect_to('index') if $self->session('username');
  $self->render;
} => 'login';

# login submission
#post '/login' => sub {
#  my $self = shift;
#  my $success;
#  {
#    my $query = "SELECT count(*) AS count FROM users WHERE username=? AND password=SHA1(?)";
#    my $sth = $dbh->prepare($query);
#    $sth->execute($self->param('username'), $self->param('password')) || die $dbh->errstr;
#    $success = $sth->fetchrow_hashref->{'count'};
#  }
#  if ($success) {
#    my $query = "UPDATE users SET last_login_on=NOW() WHERE username=?";
#    my $sth = $dbh->prepare($query);
#    $sth->execute($self->param('username')) || die $dbh->errstr;
#    $self->session( username => $self->param('username') );
#    $self->redirect_to('index');
#  } else {
#    $self->flash( message => 'Wrong username or password, please try again.' );
#    $self->redirect_to('login');
#  }
#} => 'login';

# logout
#get '/logout' => sub {
#  my $self = shift;
#  $self->session( expires => 1 );
#  $self->redirect_to('login');
#} => 'logout';

# front page
get '/' => sub {
  my $self = shift;
  # retrieve most recent article stubs
  my $iterator = Journal::Article::Manager->get_articles_iterator(
    query => [ status => 'published' ],
    limit => ($self->param('limit') || 10),
  );
  # gather list of revisions to display
  my @revision_ids;
  while (my $article = $iterator->next) {
    push(@revision_ids, $article->revision_id);
  }
  # retrieve the actual revisions
  my $revisions = Journal::Revision::Manager->get_revisions(
    query => [ id => @revision_ids ],
  );
  $self->stash( articles => $revisions );
  $self->flash( message => 'No articles found' ) unless (@$revisions);
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
  my $article = Journal::Article->new(
    status => 'published',
    id => $self->param('id'),
  )->load;
  if ($article) {
    my $revision = Journal::Revision->new( id => $article->revision_id )->load;
    $self->stash( article => $revision );
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
  # create article stub
  my $article = Journal::Article->new(
    revision_id => '0',
    topic_id => 1,
    status => 'submission',
  )->save;
  # store initial revision
  my $revision = Journal::Revision->new(
    article_id => $article->id,
    #user_id => $user->{'id'},
    user_id => 1,
    timestamp => timer(),
    title => $self->param('title'),
    dept => $self->param('dept'),
    content => $self->param('content'),
    #description => sprintf("Initial submission from %s.", $user->{'username'}),
    description => sprintf("Initial submission from anonymous"),
    format => 'html',
  )->save;
  # store revision with stub
  $article->revision_id($revision->id)->save;
  $self->flash( message => 'Thank you for your submission' );
  $self->redirect_to('index');
} => 'article_submit';

app->start;

sub timer {
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime;
  return sprintf("%4d-%02d-%02d %02d\:%02d\:%02d", ($year+1900), ($mon+1), $mday, $hour, $min, $sec);
}

sub logger {
  my %args = @_;
  my $logger = Journal::Event->new(
    timestamp => timer(),
    type => $args{'type'},
    message => $args{'message'},
  )->save;
}

