package YUM::Repo::Base;

use warnings;
use strict;

use Moo;
use MooX::Types::MooseLike::Base qw/Str HashRef Object ArrayRef/;

use XML::LibXML::Simple;
use LWP::UserAgent;
use Config::General;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use YUM::RepomdXml;

use Data::Dumper;

has base_uri => ( is => 'ro', isa=>Str, required => 1);
has uri => ( is => 'rw' , isa => Str );
has xml => ( is => 'rw', isa => Str );
has raw_struct => ( is => 'rw', isa => HashRef );
has RepoObject => ( is => 'rw', isa => Object );
has files => ( is => 'rw', isa => ArrayRef , default => sub {[]});
sub add_to_files { $_[0] && push(@{$_[0]->files},$_[1])}

sub open_xml {
    my $self = shift;
    my $repomd_xml="";
    my $xml_string;

    return $self if ($self->xml);

    $self->uri || $self->uri($self->base_uri . $self->file_name);

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

    if ($self->file_name =~ /gz$/ ) {
		gunzip \$repomd_xml => \$xml_string;
    } else {
		$xml_string = $repomd_xml;
    }	    

    $self->xml($xml_string);

    $self->raw_struct(
    	XML::LibXML::Simple->new->XMLin($xml_string,KeyAttr => ['package'])
    );	 

    $self->can('_pre_process_open') &&  $self->_pre_process_open();

    return $self;
}

return 1;
