use Test::More;

use Algorithm::SetCovering;

# Julien Gervais-Bird pointed out that in the following case, the greedy
# algorithm returns a suboptimal set of keys:
#
#         | lock1 lock2 lock3 lock4 lock5 lock6
#    -----+------------------------------------
#    key1 |   x           x           x
#    key2 |   x     x
#    key3 |               x     x
#    key4 |                           x     x
#
# The minimal set of keys to open all the locks is (key2, key3, key4),
# however the greedy algorithm will return (key1,key2,key3,key4) because
# key1 opens more locks than any other key.

my $alg = Algorithm::SetCovering->new(
    columns => 6,
    mode    => "greedy");

$alg->add_row( 1, 0, 1, 0, 1, 0 );
$alg->add_row( 1, 1, 0, 0, 0, 0 );
$alg->add_row( 0, 0, 1, 1, 0, 0 );
$alg->add_row( 0, 0, 0, 0, 1, 1 );

my @set = $alg->min_row_set(1, 1, 1, 1, 1, 1);
is("@set", "0 1 2 3", "greedy algo");

$alg->{ mode } = "brute_force";

my @set = $alg->min_row_set(1, 1, 1, 1, 1, 1);
is("@set", "1 2 3", "brute_force algo");

done_testing;
