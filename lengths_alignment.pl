#!/usr/bin/env/perl

#Calculate range of lengths for aligned COGs in a non-interleaved format. Calculate proportion of gaps in the alignment 
#and average length for each aligned COG

use strict;
use warnings;

my @files= glob "*.fas";


my @lengths;
my $total_no_aminoacids;
my $total_no_gaps;
my $total_length;
my $length;

foreach (@files) {
	
	
	if ($length) {push (@lengths, $length);}

    open my $fh, '<', $_ or die;
    my %hash;
    my $header;
    
    
    while (my $line=<$fh>) {
       		
       chomp $line;
       
       if ($line =~ m/>/) { $header=$line;}
       
       else {
		   $hash{$header}=$line;
		   $length= length $line;
		   $total_no_aminoacids+= $length;
		   
		   for (my $i=0; $i<$length; ++$i) {
			   
			   my $aa=substr ($line,$i,1);
			   if ($aa eq "-") {++$total_no_gaps;}
		   }
	   }      
    }
    $total_length+=$length;
}

my @lengths_sorted= sort {$a <=> $b} @lengths;

my $sum;

foreach (@lengths) {
	$sum+=$_;
}

my $average=$sum/3983;

my $prop_gaps= $total_no_gaps/$total_no_aminoacids;

print "$total_length\n\n";

print "Proportion of gaps: $prop_gaps\n\n";

print "Average length: $average\n\n";

print "Lengths:\n@lengths_sorted\n\n";
