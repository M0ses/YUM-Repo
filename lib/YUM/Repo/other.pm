package YUM::Repo::other;

use warnings;
use strict;

use Moo;
use MooX::Types::MooseLike::Base qw/Str/;
require YUM::Repo::Base;

extends 'YUM::Repo::Base';


has file_name => ( is => 'ro' , isa => Str, default=>sub { 'repodata/other.xml.gz' } );

return 1;
