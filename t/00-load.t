#!perl -T

use Test::More tests => 7;

BEGIN {
    use_ok( 'YUM::Repo' ) || print "Bail out!\n";
    use_ok( 'YUM::Repo::other' ) || print "Bail out!\n";
    use_ok( 'YUM::Repo::RPM' ) || print "Bail out!\n";
    use_ok( 'YUM::Repo::filelists' ) || print "Bail out!\n";
    use_ok( 'YUM::Repo::primary' ) || print "Bail out!\n";
    use_ok( 'YUM::Repo::Base' ) || print "Bail out!\n";
    use_ok( 'YUM::RepomdXml' ) || print "Bail out!\n";
}

diag( "Testing YUM::Repo $YUM::Repo::VERSION, Perl $], $^X" );
