#!/usr/bin/env perl

use strict;
use warnings;

my $comp_rcfv_file = shift @ARGV;
my @fasta_files=glob "*.fas";
my %hash;

open my $fh, '<', $comp_rcfv_file or die"Could not open file \"$comp_rcfv_file\":$!\n";

while (my $line=<$fh>){

   chomp $line;
   my @elements=split ("\t", $line);
   my $file="$elements[0]";
   
   $hash{$file}=$elements[1];
   
   system "rm $file" if $elements[1] >=0.33;
   
}

foreach (@fasta_files){
	
	if (!exists $hash{$_}){
		
		system"rm $_";
	}
}
	
	
