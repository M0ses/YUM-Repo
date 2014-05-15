use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'YUM::Repo',
    license             => 'perl',
    dist_author         => q{Frank Schreiner <m0ses+cpan@samaxi.de>},
    dist_version_from   => 'lib/YUM/Repo.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
	    'MooX::Types::MooseLike' => 0,
        'XML::LibXML::Simple'=> 0,
        'LWP::UserAgent' => 0,
        'Config::General'=>0,
        'Path::Class'=>0,
    },
    add_to_cleanup      => [ 'YUM-Repo-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
