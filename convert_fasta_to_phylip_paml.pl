#!/usr/bin/env perl

##############################################################################################################################################
#Convert fasta supermatrix in phylip format for paml (aa alignment). Ambiguous characters (X, N) are replaced with ?
###############################################################################################################################################

use strict;
use warnings;
my $in_supermatrix=shift @ARGV;
my $outfile=shift @ARGV;

#generate files
open my $fh, '<', $in_supermatrix or die "Could not open file\"$in_supermatrix\":$!\n";
open my $fh_out, '>', $outfile or die "Could not open file\"$outfile\":$!\n";

my %hash=();
my $header;
my $no_species;
my $length=0;
my $linecounter=0;

while (my $line=<$fh>){
	
	  chomp $line;
	  ++$linecounter;
	   
	  #Store fasta file in a hash 
	  if ($line=~m/^>(.+)/) {
		  
		  ++$no_species;	  
		  $header=$1;	  
	  }
	  
	  else{
	  $line=~s/X/\?/g; #substitute X with ?
	  $line=~s/\-/\?/g; #substitute - with ?
	  $hash{$header}=$line;  	  
	  }		  
	  
	  if ($linecounter==2){$length=length $line;}
}

#print no of species and length for the alignment
print {$fh_out} "$no_species $length\n";

foreach (sort (keys %hash)){
	
	printf {$fh_out} "%-40s%s\n", $_, $hash{$_};
}
	
	
	
 



