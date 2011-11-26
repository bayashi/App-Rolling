use strict;
use warnings;
use Test::More 0.88;

use File::Path qw/make_path remove_tree/;
use File::Basename;
use lib dirname(__FILE__). '/lib';
use Test::AppRolling;

use App::Rolling;

sub mk_testdir { make_path( outdir(), +{} ); }
sub outdir { dirname(__FILE__). '/out'; }
sub cleanup_testdir { remove_tree( outdir() ); }

END { cleanup_testdir(); }

my $roll = 'bin/roll';

mk_testdir();

{
    open_words_txt_as_stdin();
    system
        $^X, (map { "-I$_" } @INC),
        $roll,
        outdir().'/foo',
    ;
    is $?, 0, 'foo';
    my $file = exists_file(outdir(), qr/foo\.\d+/);
    is( (defined $file), 1, 'file exists' );
    is slurp($file), "1\n2\n3\n4\n5\n", 'content';
    restore_stdin();
}

{
    open_words_txt_as_stdin();
    system
        $^X, (map { "-I$_" } @INC),
        $roll,
        sprintf('--file=%s/bar', outdir()),
    ;
    is $?, 0, "--file";
    my $file = exists_file(outdir(), qr/bar\.\d+/);
    is( (defined $file), 1, 'file exists' );
    is slurp($file), "1\n2\n3\n4\n5\n", 'content';
    restore_stdin();
}
{
    open_words_txt_as_stdin();
    system
        $^X, (map { "-I$_" } @INC),
        $roll,
        sprintf('-f=%s/baz', outdir()),
    ;
    is $?, 0, "-f";
    my $file = exists_file(outdir(), qr/baz\.\d+/);
    is( (defined $file), 1, 'file exists' );
    is slurp($file), "1\n2\n3\n4\n5\n", 'content';
    restore_stdin();
}

cleanup_testdir();

done_testing;
