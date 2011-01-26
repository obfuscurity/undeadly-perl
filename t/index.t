
use Test::More tests => 61;
use Test::Mojo;

use FindBin;
$ENV{MOJO_HOME} = "$FindBin::Bin/../";
require "$ENV{MOJO_HOME}/index.pl";

my $t = Test::Mojo->new;

# step through anonymously
$t->get_ok('/')->status_is(200)->content_like(qr/Articles/);
$t->get_ok('/articles')->status_is(302);
$t->get_ok('/articles/1')->status_is(200)->content_like(qr/initial submission/);
$t->get_ok('/articles/add')->status_is(200)->content_like(qr/Submit Article/);
$t->get_ok('/users/add')->status_is(200)->content_like(qr/Register User Account/);
$t->get_ok('/users/confirm')->status_is(200)->content_like(qr/User Confirmation/);
$t->get_ok('/users/anonymous')->status_is(200)->content_like(qr/User Profile - anonymous/);
$t->get_ok('/logout')->status_is(302);
$t->max_redirects(1);
$t->get_ok('/roles')->status_is(404);
$t->get_ok('/topics')->status_is(404);
$t->max_redirects(0);
$t->get_ok('/404')->status_is(404);

# step through as test administrator
$t->max_redirects(1);
$t->post_form_ok('/login', {
  username => 'testy',
  password => 'changeme'
})->status_is(200)->content_like(qr/testy/);
$t->max_redirects(0);
$t->get_ok('/')->status_is(200)->content_like(qr/Articles/);
$t->get_ok('/articles')->status_is(302);
$t->get_ok('/articles/1')->status_is(200)->content_like(qr/initial submission/);
$t->get_ok('/articles/add')->status_is(200)->content_like(qr/Submit Article/);
$t->max_redirects(1);
$t->get_ok('/users/add')->status_is(200)->content_like(qr/You are already logged in/);
$t->get_ok('/users/confirm')->status_is(200)->content_like(qr/Your email has already been confirmed/);
$t->max_redirects(0);
$t->get_ok('/users/testy')->status_is(200)->content_like(qr/User Profile - testy/);
$t->get_ok('/roles')->status_is(200)->content_like(qr/Roles/);
$t->get_ok('/topics')->status_is(200)->content_like(qr/Topics/);
$t->get_ok('/404')->status_is(404);
$t->get_ok('/logout')->status_is(302);
