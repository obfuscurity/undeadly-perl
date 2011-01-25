
use Test::More tests => 29;
use Test::Mojo;

my $t = Test::Mojo->new;
$t->get_ok('/')->status_is(200)->content_like(qr/Articles/);
$t->get_ok('/articles')->status_is(302);
$t->get_ok('/articles/1')->status_is(200)->content_like(qr/initial submission/);
$t->get_ok('/articles/add')->status_is(200)->content_like(qr/Submit Article/);
$t->get_ok('/users/add')->status_is(200)->content_like(qr/Register User Account/);
$t->get_ok('/users/confirm')->status_is(200)->content_like(qr/User Confirmation/);
$t->get_ok('/users/anonymous')->status_is(200)->content_like(qr/User Profile - anonymous/);
$t->get_ok('/roles')->status_is(404);
$t->get_ok('/topics')->status_is(404);
$t->get_ok('/login')->status_is(200)->content_like(qr/Sign-Up/);
$t->get_ok('/logout')->status_is(302);

