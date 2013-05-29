package YUM::Repo::filelists;

use warnings;
use strict;

use Moo;
use MooX::Types::MooseLike::Base qw/Str/;
require YUM::Repo::RPM;
require YUM::Repo::Base;

extends 'YUM::Repo::Base';


has file_name => ( is => 'ro' , isa => Str, default=>sub { 'repodata/filelists.xml.gz' } );

return 1;
