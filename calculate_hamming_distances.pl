#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

########################################################################################################################################
#Calculate pairwise uncorrected hamming distances (proportion of differing sites) between all sequences in an alignment (fasta format).
#Input alignment must be in non-interleaved format (aa or nt)
#Mismatches due to gaps/Xs are ignored. Compares only overlapping sections of pairs without ambiguous characters (X,N,-).
#$0 -h -> prints help message
#Author:Alexandros Vasilikopoulos 2017
########################################################################################################################################

my $help;
my $in_file    = 'alignment.fas';
my $distances  = 'Hamming_distances.txt';
my $data_type  = 'aa';

GetOptions ('h'    => \$help,
            'i=s'  => \$in_file,
            'o=s'  => \$distances,
            'd=s'  => \$data_type     );
            
if ($help) {
	
print<<HELP;

###################################################################################################

$0 is used to calculate pairwise uncorrected distances in an aminoacid or 
nucleotidealignment. The output is a txt file with all distances based on 
pairwise comparisons

Usage: $0 [-Options...]

###################################################################################################

Input alignment file (non-interleaved)

-i               Default: alignment.fas

###################################################################################################

-d               Data type -> amino acid or nucleotide
                 Default: alignment.fas
                 Options: aa | nuc

-o               Output file with pairwise distances
                 Default: Hamming_distances.txt

###################################################################################################

HELP
exit;}

my $ambiguous;
if ($data_type eq "aa") {$ambiguous="X"}
elsif ($data_type eq "nuc"){$ambiguous="N";}
else {die"Unknown data type -> use option -d with either aa or nuc\n";}

my $length;

open my $fh_out, '>', $distances or die
             "Could not open file\"$distances\":$!\n";

#read alignment in a hash
my $ref_hash=&read_FASTA_in_hash($in_file);
my %hash_new=%{$ref_hash};

foreach (keys %hash_new){
	
	print "\n###  Calculate hamming distances between $_ and all its pairwise comparisons  ###\n\n";
	print {$fh_out} "\n$_\tPaiwise distances\n\n";
	sleep 1;
	
	#Pick a pair of sequences to compare
	foreach my $comparison (keys %hash_new){
		$length=scalar @{$hash_new{$_}};
		
		#skip when comparing sequence with itself
		next if $_ eq $comparison;	
		print "\nCalculate $_-$comparison pairwise Hamming distance..\n";
		
		my $value=0;
		my $gap_only_positions=0;
		my $uninformative=0;
		
       for (my $i=0;$i<$length; ++$i){
		  
		  #get values for coordinates between compared sequences
		  my $first=$hash_new{$_}->[$i];
		  my $second=$hash_new{$comparison}->[$i];
		  
		    #
		    if ((($first eq "-")          and ($second eq "-"))          or 
		        (($first eq "$ambiguous") and ($second eq "$ambiguous")) or 
		        (($first eq "$ambiguous") and ($second eq "-"))          or 
		        (($first eq "-")          and ($second eq "$ambiguous"))) 
		        
		        {++$gap_only_positions;}
		 
		    #Increase Hamming distance by 1 in case of a mismatch (ignore gaps and Xs)
		    elsif (($first  eq "-")  or 
		           ($second eq "-")  or 
		           ($first  eq "$ambiguous")  or 
		           ($second eq "$ambiguous"))
		          
		           {++$uninformative;}
			 
		    elsif ($first ne $second) {++$value;}
		    
		    
       }
       #calculate proportion of differences between compared sequences
       if ($value){

         $length=$length-($gap_only_positions+$uninformative);
         my $dist=$value/$length;
         print {$fh_out} "$_-$comparison\t$dist\n";
       }
       
       elsif (($gap_only_positions+$uninformative)==$length) {print "\nWARNING: No overlapping sequence sections for Pair $_-$comparison\n";}
    }
    print "\n\n######    Done working with $_     ######\n\n";
    sleep 1
}

###################################################################################################################################################

sub read_FASTA_in_hash {
 
 #read fasta in a hash of arrays	
 my %hash;
 my $header;	
 
 open my $fh, '<', $_[0] or die
             "Could not open file\"$in_file\":$!\n";
         
    while (my $line=<$fh>){
	
	  chomp $line;	
	  if ($line=~m/^>(.+)/){		
		$header=$1;
	  }
	
	  else{ 
		my @array=split("",$line);	
		#store sequence as an array in the hash	
		$hash{$header}= [@array];
		$length=scalar @{$hash{$header}};
	  }
    }
  close $fh;    

  return \%hash;
}
