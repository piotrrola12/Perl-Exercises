use strict;
use warnings;

use Data::Dumper;
use FindBin qw($Bin);
use lib "$Bin";

use DuplicateFiles qw(find_dups);
use Test::More 'no_plan';
use Test::Deep;
use Test::Differences;

my @subs = qw(find_dups);

use_ok( 'DuplicateFiles', @subs );
can_ok( __PACKAGE__, 'find_dups' );

my @got = find_dups( "$Bin/DirTestA/", "$Bin/DirTestB/" );
my @expected = (
	[
		"$Bin/DirTestA/file_test_1.txt",
		"$Bin/DirTestB/file_test_1.txt",
	],
	[
		"$Bin/DirTestA/file_test_3.txt",
		"$Bin/DirTestA/file_test_2.txt",
		"$Bin/DirTestB/file_test_3.txt",
		"$Bin/DirTestB/file_test_2.txt",	
	]
);

#eq_or_diff(\@got, \@expected, 'Duplicate files');
cmp_bag(\@got, \@expected);
