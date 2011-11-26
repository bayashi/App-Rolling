use strict;
use warnings;
use Test::More 0.88;

use App::Rolling;

ok 1;

if ($ENV{APP_ROLLING_ALL_TEST}) {
    system(
        $^X, (map { "-I$_" } @INC),
        'bin/roll',
        '--version'
    );
    is $?, 256, '--version';
    system(
        $^X, (map { "-I$_" } @INC),
        'bin/roll',
        '-v'
    );
    is $?, 256, '-v';

    system(
        $^X, (map { "-I$_" } @INC),
        'bin/roll',
        '--help'
    );
    is $?, 512, '--version';
    system(
        $^X, (map { "-I$_" } @INC),
        'bin/roll',
        '-h'
    );
    is $?, 512, '-v';
}

done_testing;