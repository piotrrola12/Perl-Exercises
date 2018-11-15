use strict;
use warnings;

use Data::Dumper;
use FindBin qw($Bin);
use lib "$Bin";

use DuplicateFiles qw(find_dups);
use Test::More 'no_plan';
use Test::Differences;

my @subs = qw(find_dups);

use_ok( 'DuplicateFiles', @subs );
can_ok( __PACKAGE__, 'find_dups' );

my @got = find_dups( "$Bin/DirTestA/", "$Bin/DirTestB/" );
my @expected = (
	[
		'C:/Users/Piotr/eclipse-workspace/Perl-Exercises/Duplicate-Files/DirTestA/file_test_1.txt',
		'C:/Users/Piotr/eclipse-workspace/Perl-Exercises/Duplicate-Files/DirTestB/file_test_1.txt',
	],
	[
		'C:/Users/Piotr/eclipse-workspace/Perl-Exercises/Duplicate-Files/DirTestA/file_test_2.txt',
		'C:/Users/Piotr/eclipse-workspace/Perl-Exercises/Duplicate-Files/DirTestA/file_test_3.txt',
		'C:/Users/Piotr/eclipse-workspace/Perl-Exercises/Duplicate-Files/DirTestB/file_test_2.txt',
		'C:/Users/Piotr/eclipse-workspace/Perl-Exercises/Duplicate-Files/DirTestB/file_test_3.txt',
	]
);

eq_or_diff(\@got, \@expected, 'Duplicate files');

