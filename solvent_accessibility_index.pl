#!/usr/bin/env perl

##############################################################################################################################################
#Partition amino acid supermatrix according to hydrophobicity index of Hessa et al.,  Nature 433:377 (2005). (Nature Supplementary material)
#Create 4 categories based on hydrophobicity scale. Each column from each input partition is evaluated and assigned to 1 of the 4 hydrophobicity categories.
#If one category for a partition is empty it is skipped. Modifies the partitionfile.
##############################################################################################################################################

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $median=0.71;
my $Q3=2.30;
my $Q1=-0.12;

#Define default options for reshuffling
my $input_partition_file='partitions.txt';
my $input_supermatrix='supermatrix.fas';

GetOptions ('in_partitions=s'  => \$input_partition_file,
            'in_alignment=s'   => \$input_supermatrix    );
      
#Store positions of partitions in an array of arrays
my $ref_to_partition_positions=&partitions_hash($input_partition_file);

#Store supermatrix in a hash of arrays
my $ref_to_supermatrix_hash= &supermatrix_hash($input_supermatrix);

#Create output partition file
my $outpartitions="partitions_new.txt";

open my $fh_out, '>', $outpartitions or die"Could not open file \"$file\":$!\n" ;

foreach my $gene (sort (keys %{$ref_to_partition_positions})){
	
	#generate hash for each quartile
	my @array_q1;
	my @array_q2;
	my @array_q3;
	my @array_q4;
    
	my @array=@{$$ref_to_partition_positions{$gene}};

	#loop through all positions in partition and calculate mean hydrophobicity 
	#for each position. Then partition positions within each gene according to this value (4 categories per gene).
	for (my $i=$array[0]; $i<=$array[scalar @array-1];++$i){
		
		my $sum=0;
		my $no_aa_for_position=0;
		my $average_of_position;
		
		#get aa value for each species in each position
		foreach my $header (keys %{$ref_to_supermatrix_hash}){
			 
		 my $aa=$$ref_to_supermatrix_hash{$header}->[$i-1];
		 
		   if (($aa ne "X") and ($aa ne "-")){  #skip aa if it is an ambiguous character
		   my $value=&solvent_acc($aa);	 
			 $sum+=$value;
			 ++$no_aa_for_position;
		   }
	    }
	    
	   #Calculate average hydrophobicity for position   
       if ($no_aa_for_position){	     
	      $average_of_position=$sum/$no_aa_for_position;
	     }
	   else {die"Partition $gene contains columns with only ambiguous characters\n";}
	
	   #Store headers and aa for position in category according to the average value for the column
	   if ($average_of_position<=$Q1){	
		  push (@array_q1, $i);
	   }	
		
	   elsif ($average_of_position<=$median){		
		push (@array_q2, $i);
	   }	
	
	   elsif ($average_of_position<=$Q3){		
		push (@array_q3, $i);
	   }
	
	   else{
		push (@array_q4, $i);
	   }		
	}
    
    my @arrays=(\@array_q1,\@array_q2,\@array_q3,\@array_q4); 
    my $counter=0;
    
    #Loop through each category for each gene and if category is not empty print as a separate partition
    foreach (@arrays){
		
		++$counter;
		
		if (scalar @{$_}>0){
					
			print {$fh_out} "$gene", "_$counter", " ", "=", " ";
			
			foreach my $element (@{$_}){		
				print {$fh_out} "$element"."-"."$element", " ";
			}
			
		   print {$fh_out} ";\n";
	    }
	}				
}

####################################################################################################################################
###################################################################################################################################

sub partitions_hash{  
	
	my $file=shift @_;
	my %hash;
	
	open my $fh_partitions, '<', $file or die "Could not open file \"$file\":$!\n";
	     
    while (my $line=<$fh_partitions>){
	
	  chomp $line;	
	  $line=~s/ //g;
	  $line=~s/	//g;
	  
	  #Save coordinates for partition
	  my $coordinate_1;
	  my $coordinate_2;
	  my $gene_id;
	
	     if ($line=~m/(\S+)=(\S+)\-(\S+)\;$/) {	
		   $coordinate_1=$2;
		   $coordinate_2=$3;
		   $gene_id=$1;
	     }
	
	     else {die"Input partition file not in the correct format\n";}
	
	  #Store coordinates of positions for each partition in an array
	  my @positions=($coordinate_1..$coordinate_2);
	  $hash{$gene_id}=\@positions;	
    }
    return \%hash;
}
##################################################################################################################

sub supermatrix_hash{
	
	my $file=shift @_;		
    my %hash_fasta;
    my $header;
    
    open my $fh_supermatrix, '<', $file or die "Could not open file \"$file\":$!\n";      
    
    while (my $line=<$fh_supermatrix>){
	
	  chomp $line;
	   
	  #Store fasta file in a hash of arrays
	  if ($line=~m/^>.+/) {$header=$line;}
	  
	  else{ my @array=split ("", $line); $hash_fasta{$header}=\@array;}
    }
    
   return \%hash_fasta;
}

#################################################################################################################

sub solvent_acc {

#Partition dataset according to hydrophobicity
#  Amino acid hydrophobicity scale from
#  the supplementary information for "Recognition of transmembrane 
#  helices by the endoplasmic reticulum translocon," Hessa et al., 
#  Nature 433:377 (2005).
#
#  More negative means more hydrophobic.  
#
#attribute: hhHydrophobicity
#recipient: residues

my %index_of_aminoacid= (
	"D" =>	3.49,
	"K" =>	2.71,
	"E" =>	2.68,
	"R" =>	2.58,
	"Q" =>	2.36,
	"P" =>	2.23,
	"N" =>	2.05,
	"H" =>	2.06,
	"S" =>	0.84,
	"G" =>	0.74,
	"Y" =>	0.68,
	"T" =>	0.52,
	"W" =>	0.30,
	"A" =>  0.11,
	"C" =>	-0.13,
	"M" =>	-0.10,
	"V"	=>  -0.31,
	"F" =>	-0.32,
	"L" =>	-0.55,
	"I" =>	-0.60
);

return $index_of_aminoacid{$_[0]};
}
