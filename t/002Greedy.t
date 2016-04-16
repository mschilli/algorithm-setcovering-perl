use Test::More;

use Algorithm::SetCovering;

my $alg = Algorithm::SetCovering->new(
    columns => 4,
    mode    => "greedy");

$alg->add_row(1, 0, 1, 0);
$alg->add_row(1, 1, 0, 0);
$alg->add_row(1, 1, 1, 0);
$alg->add_row(0, 1, 0, 1);
$alg->add_row(0, 0, 1, 1);

#########################
my @set = $alg->min_row_set(1, 1, 1, 1);
is("@set", "2 3", "Matching 1 1 1 1");

#########################
my @set = $alg->min_row_set(0, 0, 0, 0);
is("@set", "", "Matching 0 0 0 0");

#########################
my @set = $alg->min_row_set(0, 0, 0, 1);
is("@set", "3", "Matching 0 0 0 1");

#########################
my @set = $alg->min_row_set(0, 0, 1, 1);
is("@set", "4", "Matching 0 0 1 1");

#########################
my @set = $alg->min_row_set(0, 1, 1, 1);
is("@set", "2 3", "Matching 0 1 1 1");

######################################
# Bug fix (keys don't cover all locks)
######################################
$alg = Algorithm::SetCovering->new(
    columns => 4,
    mode    => "greedy");

$alg->add_row(1, 0, 1, 0);
$alg->add_row(1, 1, 0, 0);
$alg->add_row(1, 1, 1, 0);
$alg->add_row(0, 1, 0, 0);
$alg->add_row(0, 0, 1, 0);

#########################
my @set = $alg->min_row_set(1, 1, 1, 1);
is("@set", "", "Bugfix: Endless loop");

done_testing;
