use strict;
use warnings;
use Test::More 0.88;

use App::Rolling;

my $roll = 'bin/roll';

ok 1;

if ($ENV{APP_ROLLING_ALL_TEST}) {
    system(
        $^X, (map { "-I$_" } @INC),
        $roll,
        '--version'
    );
    is $?, 256, '--version';
    system(
        $^X, (map { "-I$_" } @INC),
        $roll,
        '-v'
    );
    is $?, 256, '-v';

    system(
        $^X, (map { "-I$_" } @INC),
        $roll,
        '--help'
    );
    is $?, 512, '--help';
    system(
        $^X, (map { "-I$_" } @INC),
        $roll,
        '-h'
    );
    is $?, 512, '-h';

    system(
        $^X, (map { "-I$_" } @INC),
        $roll,
    );
    is $?, 512, 'no args';
}

done_testing;
