use strict;
use warnings;
use Data::Dumper;

use FindBin qw($Bin);
use Storable qw(nstore retrieve);
use Digest::MD5;
use File::Find;

sub md5($) {
	my $file_name = shift;

	open( my $fh, '<', $file_name ) or warn "Can't open '$file_name': $!";
	binmode($fh);

	my $md5_hash = Digest::MD5->new->addfile($fh)->hexdigest;
	close($fh);

	return "$md5_hash";
}

sub get_files_changed {
	my @dir_list = @ARGV;

	if ( $#dir_list < 0 ) {
		print "Not specified directories to search!\n";
		return (undef);
	}

	my %real_info = ();

	find(
		sub {
			if ( -f $File::Find::name ) {
				$real_info{$File::Find::name} = md5($File::Find::name);
			}
		},
		@dir_list
	);

	my $info_file_name = "$Bin/.change.info";
	my $file_info_hashref;

	if ( -f $info_file_name ) {
		$file_info_hashref = retrieve($info_file_name);
	}

	foreach my $file ( sort keys %real_info ) {
		if ( not defined $file_info_hashref->{$file} ) {
			print "New File: '$file'\n";
		}
		else {
			if ( $file_info_hashref->{$file} ne $real_info{$file} ) {
				print "Changed File: '$file'\n";
			}
			delete $file_info_hashref->{$file};
		}
	}

	foreach my $file ( sort keys %{$file_info_hashref} ) {
		print "Removed File: '$file'\n";
	}

	nstore( \%real_info, $info_file_name );
}

get_files_changed();
