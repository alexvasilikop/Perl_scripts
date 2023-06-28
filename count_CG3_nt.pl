#!/usr/bin/env perl

#Reads fasta file and calculates average GC content of third codon positions.
#Input alignment should be according to codons.

use strict;
use warnings;

my $in_file=shift @ARGV;

open my $fh, "<", $in_file or die"Could not open file \"$in_file\":$!\n";

my %percent_of_GC3;
#my $GC3_heterogeneity;

my %seqs_of_species;
my $header;
my %GC3_species;

while (my $line=<$fh>){
	
	chomp $line;
	
	if ($line=~m/^>/){
		
		$header=$line;
	}
	
	
	else {$seqs_of_species{$header}.=$line;}
}

my $total_GC3=0;
my $no_characters;
my $no_species;
my $count=0;

foreach my $species (keys %seqs_of_species){
    
    if ($count==0){ 
		
		$no_species=scalar (keys %seqs_of_species);
		#print $no_species;
		$no_characters= ($no_species*(length $seqs_of_species{$species}))/3;
		
	}
		
	$GC3_species{$species}=0;
	
	for (my $i=2; $i<= (length $seqs_of_species{$species}); $i+=3){
			
		my $base=substr($seqs_of_species{$species}, $i, 1);
		
		if ($base=~m/G/ or $base=~m/C/){
			
		++$total_GC3;
		++$GC3_species{$species};
	    }	
	}
	
	$GC3_species{$species}=$GC3_species{$species}/($no_characters/$no_species);
		 
    ++$count;
	}
	
my $GC3_content=$total_GC3/$no_characters;
	
print $in_file, "\t", $GC3_content, "\t", $total_GC3, "\t", $no_characters, "\n"  ; 
		
	
