package YUM::Repo::primary;

use warnings;
use strict;

use Moo;
use MooX::Types::MooseLike::Base qw/Str ArrayRef/;
use YUM::Repo::RPM;
require YUM::Repo::Base;

extends 'YUM::Repo::Base';



has file_name => ( is => 'ro' , isa => Str ,required=>1, default => sub { 'repodata/primary.xml.gz' });
has package_list => (is =>'rw', isa => ArrayRef ,default=>sub { return [] } );

sub _pre_process_open {
	my $self=shift;

	foreach my $pkg_struct (@{$self->raw_struct->{package}}) {
		my $pkg = YUM::Repo::RPM
			->new(
				base_uri=>$self->base_uri,
				RepoObject=>$self->RepoObject
			)
			->data_from_struct($pkg_struct);
		$self->add_to_files($pkg_struct->{location}->{href}) if ($pkg_struct->{location}->{href});	
		$self->add_to_package_list($pkg);
	}	
}	

sub add_to_package_list {
	my $self = shift;
	my $pkg = shift;
	
	push(@{$self->package_list},$pkg);
}	
return 1;
