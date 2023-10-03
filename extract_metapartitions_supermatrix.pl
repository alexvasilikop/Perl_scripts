#!/usr/bin/env perl

###############################################################################################################
# Extract metapartitions from supermatrix (in fasta format) into separate fasta files using the charset file. Delete 
# absent taxa in each metapartition
# Author: A.Vasilikopoulos September 2017
##############################################################################################################

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

#Define default options for reshuffling
my $input_partition_file='partitions.txt';
my $input_supermatrix='supermatrix.fas';

GetOptions( 'in_partitions=s'  => \$input_partition_file,
            'in_alignment=s'   => \$input_supermatrix    );
      
#Store positions of partitions in an array of arrays
my $ref_to_partition_positions=&partitions_hash($input_partition_file);

#Store supermatrix in a hash of arrays
my $ref_to_supermatrix_hash=&supermatrix_hash($input_supermatrix);

foreach my $gene (sort (keys %{$ref_to_partition_positions})){
	
	
	my %hash_new;
	my $out_file=$gene.".fas";
	open my $fh_out, '>', $out_file or die;
	
	my @array=@{$$ref_to_partition_positions{$gene}};
	my $length=scalar @array;
	
	for (my $i=0;$i<$length;++$i){
		
		 foreach my $header (keys %{$ref_to_supermatrix_hash}){
			 
			 #generate new hash ->keys are the headers and the values are the concatenated positions
			 $hash_new{$header}.=$$ref_to_supermatrix_hash{$header}->[$array[$i]-1];
		 }
    }
    
    foreach (sort (keys %hash_new)){
	
	my $length=length $hash_new{$_};
	my $seq=$hash_new{$_};
	my $substitutions=$seq=~s/X/X/g;
	
	   if ($substitutions!=$length){
	      print {$fh_out} $_, "\n", $hash_new{$_}, "\n";
       }   
    }  
    
   close $fh_out; 
}

##################################################################################################################

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
	
	     if ($line=~m/charset(\S+)=(\S+)\-(\S+)\;$/) {	
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
 


