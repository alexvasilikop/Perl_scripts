#!/usr/bin/env/perl

#Author:A.Vasilikopoulos, 2019
##################################################################################################################
use strict;
use warnings;

my @files= glob "*.fas";
my $no_species=shift @ARGV;
#my $length_threshold=shift @ARGV;

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
   $total_characters=$length*$counter;
   my $ambiguous=$total_no_x+$total_no_gaps;

   print $_, "\t", $ambiguous/$total_characters, "\n"
	 
}
