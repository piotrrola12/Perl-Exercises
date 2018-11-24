#!/usr/perl 
use strict;
use warnings;

use Data::Dumper;
use Try::Tiny;
use FindBin qw($Bin);
use Time::ParseDate;
use Date::Calc qw(:all);

# use: remind.pl [<calender file>]
#
# File Format:
#   data<tab>displacement<tab>Event

#########################################################
# time_to_YMD -- converts unit time to year, mont and day
#########################################################

sub time_to_YMD($) {
    my $time = shift; #seconds

    my @local = localtime($time);
    return ($local[5] + 1900, $local[4] + 1, $local[3]);
}

my $in_file = $ENV{'HOME'} . "/calendar";
my @today_YMD = time_to_YMD(time());

if ($#ARGV == 0) {
    $in_file = $ARGV[0];
}

if ($#ARGV > 0) {
    print STDERR "Uses: $0 [calendar-file]\n";
}

unless ( -f $in_file ) {
    print STDERR "Please use: [calendar-file]\n";
    exit(0);
}

open( IN_FILE, $in_file ) or die "Can't open the file '$in_file' to read: $!";

while(<IN_FILE>) {
    # row beginning with the char # are comments
    if ($_ =~ /^\s+#/) {
        next;
    }

    # skip empty row
    if ($_ =~ /^\s*$/) {
        next;
    }

    # row with data
    my @data = split /\t+/, $_, 3;
    if ($#data != 2) {
        next;
    }

    my $date = parsedate($data[0]);
    if ( not defined($date) ) {
        print STDERR "I can not understand date '$date'\n";
        next;
    }

    my @file_YMD = time_to_YMD($date);

    # Difference between @today_YMD and @file_YMD
    my $diff = Delta_Days(@today_YMD, @file_YMD);
    #my $diff = Delta_Days( (2018, 11, 24), (2018, 11, 30) );

    if ( $data[1] > 0 ) {
        if ( ($diff > 0) && ($diff < $data[1]) ) {
            print "$diff $data[2]\n";
        }
    }
    else {
        if ( ($diff < 0) && ($diff > $data[1]) ) {
            print "$diff $data[2]\n";
        }
    }
}
