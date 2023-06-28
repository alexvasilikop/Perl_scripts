#!/usr/bin/env/perl

#Keep only metapartition files with a user specified threshold for no. of species and number of amino acid sites.
#Filter further based on total number of ambiguous sites. Here threshold 30%.

use strict;
use warnings;

my @files= glob "*.fas";
my $no_species=shift @ARGV;
my $length_threshold=shift @ARGV;

#Loop through each file
foreach (@files) {

   open my $fh, '<', $_ or die;
   
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
		   my $no_x=$line=~s/X/X/g;
		   my $no_gaps=$line=~s/-/-/g;
		   
		   $total_no_x+=$no_x;
		   $total_no_gaps+=$no_gaps;   
		   
		   }
   }
   
   close $fh; 
   my $total_characters=$length*$no_species;
   my $ambiguous=$total_no_x+$total_no_gaps;

      #filter fasta files
	  if ($counter<$no_species){
		  system "rm $_";
	  }
	  
	  if ($length<$length_threshold) {
		  system "rm $_" if -f $_;
	  }
	  
	  if ($ambiguous>=(1-($total_characters*0.7))) {
		  system "rm $_" if -f $_;
	  }
	 
}
