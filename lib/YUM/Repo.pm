package YUM::Repo;

use warnings;
use strict;

use Moo;
use MooX::Types::MooseLike::Base qw/Str HashRef ArrayRef/;
use Data::Dumper;
use File::Path qw/make_path/;
use File::Basename;
use LWP::Simple;
use Path::Class;
use URI;

require YUM::RepomdXml;


=head1 NAME

YUM::Repo - Read, search and sync YUM Repositories

=head1 VERSION



=cut

our $VERSION = '0.000101';

=head1 METHODS/ACCESSORS

=head2 uri

uri to repository (directory which contains repodata directory)

	e.g. http://centos.psw.net/centos/6.4/isos/x86_64/

=cut

has uri => ( is => 'ro' , required => 1, isa => Str );

=head2 repomd

YUM::RepomdXml object

=cut

has repomd => (is => 'rw' , isa=>sub { die "$_[0] is not a YUM::RepomdXml\n" if (ref($_[0]) ne 'YUM::RepomdXml') } );
has primary => (is => 'rw' );
has filelists => (is => 'rw' );
has other => (is => 'rw' );
has provides => (is=>'rw', isa => HashRef, default => sub { return {} });
has files => (is=>'rw', isa => ArrayRef, default => sub { [qw(repodata/repomd.xml repodata/repomd.xml.asc repodata/repomd.xml.key)] });

=head2 repomd_xml

opens repository and returns YUM::RepomdXml object

=cut

sub repomd_xml {
	my $self = shift;

	$self->repomd(YUM::RepomdXml->new(base_uri=>$self->uri,RepoObject=>$self));

	$self->repomd->open_repo;

	map { $self->$_($self->repomd->$_) } qw/primary filelists other/;

	return $self->repomd;
}	

=head2 who_provides

method to find the packages which provides the specified library

	$repo->who_provides('perl(Moo)');

=cut

sub who_provides {
	my $self = shift;
	my $query = shift;

	my @result;
        map { push(@result,$_->{pkgName}) }  @{$self->{provides}->{$query}};

	return \@result;
}	


=head2 add_to_provides

method to enhance provides hash, wich contains a list of packages

	$repo->who_provides('perl(Moo)');

=cut

sub add_to_provides {
	my $self = shift;
	my $name = shift;
	my $data = shift;
	my %dataSet = %{$data};
	$dataSet{pkgName}=$name;
	push(@{$self->{provides}->{$data->{name}}},\%dataSet);

	return $self;
}

=head2 sync_to

sync remote repository to local directory

=cut

sub sync_to {
	my ($self,$sync_to_dir) = @_;
	my $unique_path = {};
	my @filelist = ();

	foreach my $file (
		@{$self->files},
		@{$self->repomd->files},
		@{$self->primary->open_xml->files}
	)
	{
		push(@filelist,$file);
		my $dir = dir($sync_to_dir,dirname($file));
		$unique_path->{$dir}=1;
		
	}	

	map { -d $_ || make_path($_) } ($sync_to_dir,(keys(%{$unique_path})));

	foreach my $file (@filelist) {
		my $rpm_lpath 	= file($sync_to_dir,$file);
		my $uri = URI->new_abs($file,$self->uri);	
		print "$uri -> $rpm_lpath\n";
		is_error(mirror($uri,$rpm_lpath)) &&
			die "Error while syncing <$uri> to <$rpm_lpath>\n";
	}	

	return 1;	
	
}	

return 1;
