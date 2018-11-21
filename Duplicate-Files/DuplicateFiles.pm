package DuplicateFiles;

use Data::Dumper;
use Try::Tiny;
use File::Find;
use Digest::MD5;
use Exporter;
use FindBin qw($Bin);
use Storable qw(retrieve nstore);

@ISA = qw(Exporter);

our @EXPORT_OK = qw(
  find_dups
);

=begin nd

Function: find_dups

Parameters:
	list of directories to search: @directories_to_search
	
Return:
	list of duplicate files
	
=cut

#sub get_md5_files(@) {
#	my $files_array_ref = shift;
#
#	my %md5 = ();
#
#	foreach my $file ( @{$files_array_ref} ) {
#		try {
#			if ( defined $buffer_memory_file->{$file} ) {
#				push @{ $md5{ $buffer_memory_file->{$file} } }, $file;
#			}
#			else {
#
#				open( my $fh, '<', $file )
#				  or warn "Can't open '$file': $!" && next;
#				binmode($fh);
#
#				push @{ $md5{ Digest::MD5->new->addfile($fh)->hexdigest } },
#				  $file;
#				close($fh);
#			}
#		}
#		catch {
#			warn "Caught error: $_";
#		}
#	}
#
#	return %md5;
#}

sub get_files_by_size(@) {
	my @dir_list = @_;

	my %files = ();

	find(
		sub {
			if ( -f $File::Find::name ) {
				push @{ $files{ -s $File::Find::name } }, $File::Find::name;
			}
		},
		@dir_list
	);

	return %files;
}

sub find_dups(@) {

	# Directories to search
	my @dir_list = @_;

	if ( $#dir_list < 0 ) {
		return (undef);
	}

	# Files arranged by size
	my %files = get_files_by_size(@dir_list);

	# Resulting list
	my @result = ();

	my $memory_file  = "$Bin/.memory_file.info";
	my $memory_file_hashref;
	
	if (-f $memory_file) {
		$memory_file_hashref = retrieve($memory_file);
	}
	
	foreach my $size ( keys %files ) {
		if ( $#{ $files{$size} } < 1 ) {
			next;
		}
		
		my %md5 = ();

		foreach my $file ( @{$files{$size}} ) {
			try {
				if ( $memory_file_hashref->{$file} ) {
					push @{ $md5{ $memory_file_hashref->{$file} } }, $file;
				}
				else {
					open( my $fh, '<', $file ) or warn "Can't open '$file': $!" && next;
					binmode($fh);
					
					my $hash = Digest::MD5->new->addfile($fh)->hexdigest;

					push @{ $md5{$hash} }, $file;
					
					# save data to buffer memory file
					$memory_file_hashref->{$file} = $hash;
					close($fh);
				}
			}
			catch {
				warn "Caught error: $_";
			}
		}

		# Check if any MD5 hash repeated
		foreach my $hash ( keys %md5 ) {
			if ( $#{ $md5{$hash} } < 1 ) {
				next;
			}
			push @result, [ @{ $md5{$hash} } ];
		}
	}
	
	nstore($memory_file_hashref, $memory_file); 
	return @result;
}

1;
