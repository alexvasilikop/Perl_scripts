#!/usr/bin/env perl

##############################################################################################################################################
#Reduce supermatrix according to site coverage based on user defined threshold (for aa supermatrix).
#Usage: perl $0 -in_alignment <superalignment_non-interleaved_fasta_format> -threshold <coverage_threshold>
#Author 2017:A. Vasilikopoulos
##############################################################################################################################################

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

#Define default options for subsampling
my $input_supermatrix='supermatrix.fasta';
my $threshold = 0.90;
my $outfile='supermatrix_new.fas';

GetOptions ('in_alignment=s'=> \$input_supermatrix,
            'threshold=f'   => \$threshold,
            'out=s'         => \$outfile           
                                                    );

#Store supermatrix in a hash of arrays. Store length and number of species for the supermatrix
my @supermatrix_hash_length_species = &supermatrix_hash($input_supermatrix);
my $length = $supermatrix_hash_length_species[1];
my $no_species= $supermatrix_hash_length_species[2];

#new hash to reduce the dataset
my %new_hash_reduced;

for(my $i=0; $i<$length;++$i){
		
		#generate new hash for position
		my $no_ambiguous_for_position=0;
		my %hash_for_position=();
		
		#get aa value for each species in each position
		foreach my $header (sort (keys %{$supermatrix_hash_length_species[0]})){
		
		#print $header, "\n";	 
		my $aa=$supermatrix_hash_length_species[0]{$header}->[$i];
		 
		#print $aa, "\n";
		$hash_for_position{$header}=$aa;
		 
		   if (($aa eq "X") or ($aa eq "-")){  #count ambiguous
			 ++$no_ambiguous_for_position;
		   }
	    }
	    
	   #Check if no of ambiguous exceeds the threshold   
       if (($no_ambiguous_for_position/$no_species)<=(1-$threshold)){
		   	    
		  #print  $no_ambiguous_for_position;
	      
	      foreach my $header (keys %hash_for_position){
	      
	      #concatenate aa sites for each species
	      $new_hash_reduced{$header}.=$hash_for_position{$header};
	      #print $new_hash_reduced{$header}, "\n";
	      
	      }
	   }
}

open my $fh_out, '>', $outfile or die"Could not open file\"$outfile\":$!\n";

foreach my $key (sort (keys %new_hash_reduced)){
	
	print {$fh_out} "$key","\n", $new_hash_reduced{$key}, "\n";
}

##################################################################################################################

sub supermatrix_hash{
	
	my $file=shift @_;		
    my %hash_fasta;
    my $header;
    my $length;
    my $no_species=0;
    
    open my $fh_supermatrix, '<', $file or die "Could not open file \"$file\":$!\n";      
    
    #read supermatrix in a hash of arrays
    while (my $line=<$fh_supermatrix>){
	
	  chomp $line;
	   
	  #Store fasta file in a hash of arrays
	  if ($line=~m/^>.+/) {$header=$line;++$no_species}
	  
	  else{ 
		  my @array=split ("", $line); 
		  $hash_fasta{$header}=\@array;
		  
		  #calculate length of supermatrix
		  if (!defined $length){
			  $length=scalar @array;
		  }		  
	  }
    }
   #return length and hash of arrays
   return (\%hash_fasta, $length, $no_species);
}
