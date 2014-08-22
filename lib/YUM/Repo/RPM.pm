package YUM::Repo::RPM;

use warnings;
use strict;

use Moo;
use MooX::Types::MooseLike::Base qw/Str ArrayRef Object HashRef/;

use Data::Dumper;

has base_uri => ( is => 'ro' , isa => Str, required=>1);
has name => ( is => 'rw' , isa => Str );
has arch => ( is => 'rw' , isa => Str );
has description => ( is => 'rw' , isa => Str );
has summary => ( is => 'rw' , isa => Str );
has url => ( is => 'rw' , isa => Str);
around 'url' => sub { 
	my $orig = shift;
	my $self = shift;
	my $url = shift;
	$url = (ref($url)) ? '' : $url;
	return $self->$orig($url);
};	
has type => ( is => 'rw' , isa => Str );

# attributes in $xml->{package}->[$i]->{format}
has license => ( is => 'rw' , isa => Str);
has group => ( is => 'rw' , isa => Str);
has file => ( is => 'rw' , isa => ArrayRef);
around file => sub {
	my $orig = shift;
	my $self = shift;
	my $param = shift;
	$param = (ref($param) eq 'ARRAY') ? $param : [$param];
	return $self->$orig($param);

};
has buildhost => ( is => 'rw' , isa => Str);
has vendor => ( is => 'rw' , isa => Str);
has sourcerpm => ( is => 'rw' , isa => Str);
has RepoObject => ( is => 'rw' , isa => Object );
has header_range => ( is => 'rw' , isa => HashRef, default => sub {return{}} );

sub data_from_struct {
	my $self = shift;
	my $struct = shift;

	foreach my $attr (qw/name arch description summary url type/) {
		my $content = (ref($struct->{$attr})) ? '' : $struct->{$attr};
		$self->$attr($content);
	}

	foreach my $key (keys(%{$struct->{format}})) {
		my $attr=$key;
		$attr =~ s/^rpm://;
		$attr =~ s/-/_/g;

#		print "attr: $attr\n".Dumper($struct->{format}->{$key});

		if ($self->can($attr) ) {
			### FIXME:
			# this is only a dirty hack because if sourcerpm is empty
			# it leads to a hashRef (evtl. given by XML Parser Implementation)
			# This hashRef breaks our attribute definition
			my $tmpAttr='';
			if ($attr eq 'sourcerpm' && ref($struct->{format}->{$key}) eq 'HASH') {
				if (keys(%{$struct->{format}->{$key}}) > 0) {
					warn 				
						"attr: $attr key:$key\n" .
						Dumper($struct->{format}->{$key});
				}		
			} else {	
				$tmpAttr = $struct->{format}->{$key} || '';
			}
			#
			#### /FIXME

			$self->$attr($tmpAttr);
		} else {
			warn "method <$attr> not implemented yet!\n";
		}	
	}	

	return $self
}	

sub requires	{ my $s = shift; return $s->__base_deps('requires',@_);}	
sub obsoletes	{ my $s = shift; return $s->__base_deps('obsoletes',@_);}	
sub suggests	{ my $s = shift; return $s->__base_deps('suggests',@_);}	
sub recommends	{ my $s = shift; return $s->__base_deps('recommends',@_);}	
sub conflicts	{ my $s = shift; return $s->__base_deps('conflicts',@_);}	
sub supplements { my $s = shift; return $s->__base_deps('supplements',@_);}	

sub provides {
	my $self = shift;

	my $result = $self->__base_deps(
		'provides',
		shift
	);	

	if (ref($self->RepoObject) eq 'YUM::Repo' ) {
		foreach my $dep (@{$self->{provides}}) {
			$self->RepoObject->add_to_provides(
				$self->name,
				$dep
			);	
		}	
	}	

	return $result;
}

sub __base_deps {
	my $self = shift;
	my $dep_type = shift;
	my $opt = shift;

	if (! $self->{$dep_type} ) {
		$self->{$dep_type} = [];
	}	

	return $self->{$dep_type} if ( ! $opt || ! ref($opt) );

	if (ref($opt->{'rpm:entry'}) eq 'ARRAY') {
		$self->{$dep_type} = $opt->{'rpm:entry'}
	} elsif ( ref($opt) eq 'ARRAY') {
		$self->{$dep_type} = $opt;
	} elsif (ref($opt->{'rpm:entry'}) eq 'HASH') {
		$self->{$dep_type} = [ $opt->{'rpm:entry'} ]
	}

	return $self->{$dep_type}
}	

return 1;
