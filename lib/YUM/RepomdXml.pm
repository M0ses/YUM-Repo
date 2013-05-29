package YUM::RepomdXml;

use warnings;
use strict;

use Moo;
use MooX::Types::MooseLike::Base qw/Str Object HashRef ArrayRef/;

use XML::LibXML::Simple;
use LWP::UserAgent;
use Config::General;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;

use Data::Dumper;

use YUM::Repo::primary;
use YUM::Repo::filelists;
use YUM::Repo::other;

our $VERSION = '0.001';

has base_uri => ( is => 'ro', isa=>Str, required=>1 );
has uri => ( is => 'rw', isa => Str );
has xml => ( is => 'rw', isa => Str );
has primary => ( is => 'rw', isa => Object );
has other => ( is => 'rw', isa => Object ); #('YUM::Repo::other') );
has filelists => ( is => 'rw', isa => Object );#'YUM::Repo::filelists' );
has RepoObject => ( is => 'rw', isa => Object );#'YUM::Repo::filelists' );
has raw_struct => ( is => 'rw', isa => HashRef );
has files => ( is => 'rw', isa => ArrayRef , default => sub {[]});
sub add_to_files { $_[0] && push(@{$_[0]->files},$_[1])}	

sub open_repo {
	my $self = shift;
	my $repomd_xml="";

	return $self if ($self->xml);

	$self->uri || $self->uri($self->base_uri . "/repodata/repomd.xml");

	my $ua = LWP::UserAgent->new;
	
	my $response = $ua->get($self->uri);

	if ($response->is_success) {
		 $repomd_xml = $response->decoded_content;  # or whatever
	}
	else {
		die 
			"Error while Fetching ".$self->uri."\n" .
			$response->status_line ."\n";
	}

	$self->xml($repomd_xml);
	$self->raw_struct(XML::LibXML::Simple->new->XMLin($repomd_xml));

	my $type2Class = {
		primary=>'YUM::Repo::primary',
		other=>'YUM::Repo::other',
		filelists=>'YUM::Repo::filelists',
	};

	foreach my $data (@{$self->raw_struct->{data}}) {

		my $type = $data->{type};

		$self->add_to_files($data->{location}->{href}) if ($data->{location}->{href});

		print " type_class $type in queue\n" if ($main::DEBUG);

		my $type_class = $type2Class->{$type};

		if ( $type_class ) {
			print "  Generating $type_class\n" if ($main::DEBUG);
			my $obj = $type_class->new(
				file_name=>$data->{location}->{href},
				base_uri=>$self->base_uri,
				RepoObject=>$self->RepoObject
			);
			$self->$type($obj);
		}			
	}		
	return $self;
}


return 1;
