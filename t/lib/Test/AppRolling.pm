package Test::AppRolling;
use strict;
use warnings;
use Carp qw/croak/;
use parent 'Exporter';
our @EXPORT = qw/
    open_words_txt_as_stdin restore_stdin
    exists_file slurp
/;

use File::Basename;
use File::Spec;
use IO::Dir;
use IO::File;

my $REAL_STDIN;

sub open_words_txt_as_stdin {
    my $file = shift;

    if (!defined($file)) {
        $file = 'test.txt';
    }

    my $test_txt = File::Spec->catfile(
        dirname(dirname(__FILE__)),
        'share',
        $file
    );

    $REAL_STDIN = *STDIN;
    close(STDIN);
    open(*STDIN, '<', $test_txt)
        or die "Unable to open $test_txt for reading";
}

sub restore_stdin {
    close(STDIN);
    *STDIN = $REAL_STDIN;
}

sub exists_file {
    my ($dir, $regex) = @_;

    my $d = IO::Dir->new($dir) or croak $!;
    if (defined $d) {
        while ( my $file = $d->read ) {
            return "$dir/$file" if $file && $file =~ m!$regex!;
        }
    }
    return; # not exists
}

sub slurp {
    my ($file) = shift;

    my $fh = IO::File->new($file, 'r') or croak $!;
    my $content = join '', $fh->getlines;
    undef $fh;
    return $content;
}

1;
