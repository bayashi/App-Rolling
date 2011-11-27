package App::Rolling;
use strict;
use warnings;
use Carp qw/croak/;
use Getopt::Long qw/GetOptionsFromArray/;
use Pod::Usage;
use Path::Class qw/dir file/;
use IO::File;
use IO::Interactive qw/is_interactive/;

our $VERSION = '0.10';

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
        't|through'    => \$config{through},
        'nr|no-rotate' => \$config{no_rotate},
        'h|help'       => sub {
            pod2usage(2);
        },
        'v|version'     => sub {
            print "roll v$App::Rolling::VERSION\n";
            exit 1;
        },
    ) or pod2usage(2);

    $config{file} = shift @argv unless $config{file};

    $config{age}      = 5  unless $config{age};
    $config{interval} = 60 unless $config{interval};

    return %config;
}

sub _config_read {
    my $self = shift;

    my $filename = $self->_config_file;

    return unless -e $filename;

    my $fh = IO::File->new($filename, '<')
        or croak "[ERROR] couldn't open config file $filename: $!";

    my %config;
    while (<$fh>) {
        chomp;
        next if /\A\s*\Z/sm;
        if (/\A(\w+):\s*(.+)\Z/sm) { $config{$1} = $2; }
    }

    undef $fh;

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

    if ( !is_interactive() ) {
        while ( my $line = <STDIN> ) {
            my $age_id = int(time / $config{interval});
            my $now_suffix = $config{no_rotate} ? '' : '.' . $age_id;
            if (!$config{no_rotate} && $config{age}) {
                my $old_suffix = $age_id - $config{age};
                if (-e "$config{file}\.$old_suffix") {
                    unlink "$config{file}\.$old_suffix";
                }
            }
            my $file = "$config{file}$now_suffix";
            my $fh = IO::File->new($file, '>>')
                        or croak "[ERROR] could't open file $file: $!";
            $fh->print($line);
            undef $fh;
            print $line if $config{through};
        }
    }
}

1;

__END__

=encoding UTF-8

=head1 NAME

App::Rolling - rotate input stream into pieces automatically


=head1 SYNOPSIS

    use App::Rolling;
    App::Rolling->run(@ARGV);


=head1 DESCRIPTION

App::Rolling is the module for rotating input stream into pieces automatically.
you can use L<roll> command.

Example:
    $ /usr/sbin/tcpdump | roll -f /tmp/dump

see more documents about L<roll>.


=head1 METHOD

=head2 run(@args)

start rolling


=head1 REPOSITORY

App::Rolling is hosted on github
<http://github.com/bayashi/App-Rolling>


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO

L<roll>


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
