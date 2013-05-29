#!/usr/bin/env perl
#

#
# synchronization of a obs repository to a local filesystem
#

use strict;
use warnings;
use Getopt::Long;

my ($repo_url, $destination);
my $result = GetOptions ("repo_url=s" => \$repo_url, # numeric
		"destination=s" => \$destination, # string
		); # flag

if(!$repo_url || !$destination){
	print "Usage:\n";
	print "\n";
	print $0.' --repo=<repo url> --dest=<target path>'."\n";
	print 'repo url: http://obs.isarnet.lab:82/4.8.1:/IsarNet:/Perl/SLE_11_SP2/'."\n";
	print "\n";
	exit 1;
}



use YUM::Repo;
use Data::Dumper;

print "Starting ...\n";

my $REPO_URL=$repo_url;

my $yum = YUM::Repo->new(uri=>$REPO_URL);
my $repomd_xml = $yum->repomd_xml();
#$yum->other->open_xml;
#print Dumper($yum->repomd_xml->files);
#print Dumper($yum->primary->open_xml->files);

$yum->sync_to($destination);

exit 0;
