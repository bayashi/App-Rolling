package App::Rolling;
use strict;
use warnings;
use Carp qw/croak/;
use Getopt::Long qw/GetOptionsFromArray/;
use Pod::Usage;
use Path::Class qw/dir file/;
use IO::File;

our $VERSION = '0.01';

sub run {
    my ($class, @argv) = @_;

    my %config = $class->_process(@argv);

    if (!$config{file}) {
        croak "-f --file is required";
    }
    else {
        $class->_roll(%config);
    }

    return 1;
}

sub _process {
    my ($self, @argv) = @_;

    my %config = $self->_config_read;

    pod2usage(2) unless @argv;

    GetOptionsFromArray(
        \@argv,
        'f|file=s'     => \$config{file},
        'a|age=i'      => \$config{age},
        'i|interval=i' => \$config{interval},
        'h|help'       => sub {
            pod2usage(1);
        },
        'v|version'     => sub {
            print "roll v$App::Rolling::VERSION\n";
            exit 1;
        },
    ) or pod2usage(2);

    croak "[ERROR] specify file" unless $config{file};
    $config{age}      = 5  unless $config{age};
    $config{interval} = 60 unless $config{interval};

    return %config;
}

sub _config_read {
    my $self = shift;

    my $filename = $self->_config_file;

    return unless -e $filename;

    open my $fh, '<', $filename
        or croak "[ERROR] couldn't open config file $filename: $!\n";

    my %config;
    while (<$fh>) {
        chomp;
        next if /\A\s*\Z/sm;
        if (/\A(\w+):\s*(.+)\Z/sm) { $config{$1} = $2; }
    }

    return %config;
}

sub _config_file {
    my $self = shift;

    my $configdir = $ENV{'ROLLING_DIR'} || '';

    if ( !$configdir && $ENV{'HOME'} ) {
        $configdir = dir( $ENV{'HOME'}, '.rolling' );
    }

    return file($configdir, 'config');
}

sub _roll {
    my ($self, %config) = @_;

    if (!-t STDIN) {
        while ( my $line = <STDIN> ) {
            my $now_suffix = int(time / $config{interval});
            my $old_suffix = $now_suffix - $config{age};
            if (-e "$config{file}\.$old_suffix") {
                unlink "$config{file}\.$old_suffix";
            }
            my $fh = IO::File->new("$config{file}\.$now_suffix", '>>')
                        or croak "could't open log: $config{file}\.$now_suffix";
            $fh->print($line);
            undef $fh;
        }
    }
}

1;

__END__

=head1 NAME

App::Rolling - one line description


=head1 SYNOPSIS

    use App::Rolling;


=head1 DESCRIPTION

App::Rolling is


=head1 REPOSITORY

App::Rolling is hosted on github
<http://github.com/bayashi/App-Rolling>


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
