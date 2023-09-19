#!/usr/bin/env perl

#move fasta files with less than 4 species in a different directory

use strict;
use warnings;

my @files=glob"*.fas";
chomp @files;

foreach (@files){
	
	my $no_species=0;
	
	open my $fh, "<", $_ or die;
	
	while(my $line=<$fh>){
		
		chomp $line;
		if ($line=~m/^>.+/){
		++$no_species;	
	    }
    }
    
    if ($no_species<4){
		close $fh;
		system "mv $_ /home/av/Desktop/Dytiscoidea_paper/09b_Remove_alignments_with_less_than_3_taxa/aa/removed_genes/";
		}
}
			
		
			
