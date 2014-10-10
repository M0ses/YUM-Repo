#!/usr/bin/env perl
#

#
# synchronization of a obs repository to a local filesystem
#

use strict;
use warnings;
use Getopt::Long;

my ($repo_url, $destination)=("http://linux.dell.com/repo/hardware/latest/platform_independent/suse11_64/",'');
my $result = GetOptions ("repo_url=s" => \$repo_url, # numeric
		"destination=s" => \$destination, # string
		); # flag

if(!$repo_url || !$destination){
	print "Usage:\n";
	print "\n";
	print $0.' --repo=<repo url> --dest=<target path>'."\n";
	print "repo url: $repo_url\n";
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
#
my @package_list=$yum->primary->open_xml->package_list;
#print Dumper($yum->primary->open_xml->package_list);

$yum->sync_filtered(
    destination             =>    $destination,
    include_package_list    => ['srvadmin-all'],
    skip_repodata           => 1,
    filter                  =>
    sub {
        my ($rpm,$opts) = @_;
        if ( 
            $rpm->{name} ~~ @{$opts->{include_package_list}} &&
            $rpm->{type} eq 'rpm'
        ) {
            return 1
        }
        return 0
    }
);

exit 0;
