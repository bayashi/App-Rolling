use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::Rolling',
    license             => 'perl',
    dist_author         => 'Dai Okabayashi <bayashi@cpan.org>',
    dist_version_from   => 'lib/App/Rolling.pm',
    build_requires      => {
        'Test::More' => 0.88,
    },
    requires => {
        'Carp' => 0,
    },
    add_to_cleanup      => [ 'App-Rolling-*' ],
    meta_merge     => {
      resources => {
        repository  => 'http://github.com/bayashi/App-Rolling'
      }
    },
);

$builder->create_build_script();