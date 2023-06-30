#!/usr/bin/env perl

#Keep only metapartition files with a user specified threshold for no. of species, alignment length, and proportion of missing data.
#Filter further based on total number of ambiguous sites. Here threshold less than 30%.
#Author:A.Vasilikopoulos, 2017
##################################################################################################################
use strict;
use warnings;

my @files= glob "*.fas";
my $no_species=shift @ARGV;
my $length_threshold=shift @ARGV;

#Loop through each file
foreach (@files) {

   open my $fh, '<', $_ or die"Could not open file \"$_\":$!\n";
   
   #statistics variables
   my $counter=0;
   my $length=0;
   my $total_no_x=0;
   my $total_no_gaps=0;
   my $total_characters=0;
   
   while (my $line=<$fh>){
	   
	   chomp $line;
  
	   if ($line=~m/^>/){
		   ++$counter;
	   }
	   
	   else {
		   $length=length $line;
		   #count ambiguous
		   my $no_x=$line=~s/X/X/g;
		   my $no_gaps=$line=~s/-/-/g;
		   
		   $total_no_x+=$no_x;
		   $total_no_gaps+=$no_gaps;   
		   
		   }
   }
   
   close $fh; 
   $total_characters=$length*$no_species;
   my $ambiguous=$total_no_x+$total_no_gaps;

      #filter fasta files
	  if ($counter<$no_species){ #filter acc. to no. species
		  system "rm $_";
	  }
	  
	  if ($length<$length_threshold) { #filter acc. to alignment length
		  system "rm $_" if -f $_;
	  }
	  
	  if ($ambiguous>=($total_characters*0.3)) { #filter acc. to missing data threshold
		  system "rm $_" if -f $_;
	  }
	 
}
