package DuplicateFiles;

use Data::Dumper;
use Try::Tiny;
use File::Find;
use Digest::MD5;
use Exporter;

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

sub get_md5_files(@) {
	my $files_array_ref = shift;

	my %md5 = ();
	
	foreach my $file ( @{$files_array_ref} ) {
		try {
			open( my $fh, '<', $file ) or warn "Can't open '$file': $!" && next;
			binmode($fh);

			push @{ $md5{ Digest::MD5->new->addfile($fh)->hexdigest } }, $file;
			close($fh);
		}
		catch {
			warn "Caught error: $_";
		}
	}
	
	return %md5;
}

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

	foreach my $size ( keys %files ) {
		if ( $#{ $files{$size} } < 1 ) {
			next;
		}
		
		my %md5 = get_md5_files( $files{$size} );

		# Check if any MD5 hash repeated
		foreach my $hash ( keys %md5 ) {
			if ( $#{ $md5{$hash} } < 1 ) {
				next;
			}
			push @result, [ @{ $md5{$hash} } ];
		}
	}
	
	return @result;
}

1;
