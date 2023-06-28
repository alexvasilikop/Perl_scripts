#!usr/bin/env perl

###############################################################################################################
# Reshuffle positions within different partitions in a supermatrix. Input supermatrix should be in 
# non-interleaved fasta format. Partitions in the partition file should be ordered according to their 
# order in the input supermatrix. Reshuffling is made only within each partition and output supermatrix has 
# exacly the same no. of positions and partitions in the same order.
# Usage: $0 -in_alignment name_of_supermatrix.fas -no_reshuffling #no replicates -in_partitions partition_table.txt
# Author: A.Vasilikopoulos June 2017
##############################################################################################################

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

#Define default options for reshuffling
my $no_reshuffling=1;
my $input_partition_file='partitions.txt';
my $input_supermatrix='supermatrix.fas';

GetOptions( 'no_reshuffling=i' => \$no_reshuffling,
            'in_partitions=s'  => \$input_partition_file,
            'in_alignment=s'   => \$input_supermatrix    );
      
#Store positions of partitions in an array of arrays
my $ref_to_partition_positions=&partitions_hash($input_partition_file);

#Store supermatrix in a hash of arrays
my $ref_to_supermatrix_hash=&supermatrix_hash($input_supermatrix);

#Generate  # no of replicate reshuffled supermatrices
for (my $replicates=1;$replicates<=$no_reshuffling;++$replicates){      
	
  my $new_supermatrix="reshuffled_supermatrix_$replicates.phy";
  my %hash_new;
  my $total_length=0;

  foreach (@{$ref_to_partition_positions}){
	
	my @array=@{$_};
	my $length=scalar @array;
	$total_length+=$length;
	
	for (my $i=0;$i<$length;++$i){
		
		#pick a random index from array with positions for each partition
		my $random_index=int (rand @array);
		
		#pick the corresponding position for the randomly selected index
		my $random_element=$array[$random_index];
		
		 foreach my $header (keys %{$ref_to_supermatrix_hash}){
			 
			 #generate new hash ->keys are the headers and the values are the concatenated randomly selected positions
			 $hash_new{$header}.=$$ref_to_supermatrix_hash{$header}->[$random_element-1];
		 }		 
	 #remove position if already used->Non-redundant output of positions
	 splice (@array, $random_index,1);		
	}
  }

  #print new supermatrix in fasta format
  open my $fh_out, '>', $new_supermatrix or die "Could not open file \"$new_supermatrix\":$!\n";   

  my $no_species=scalar (keys %hash_new);
  print {$fh_out} $no_species." ".$total_length, "\n";

  foreach (sort (keys %hash_new)){
	$_=~s/>//g;
	print {$fh_out} $_, " ", $hash_new{">$_"}, "\n";
  }
}
##################################################################################################################

sub partitions_hash{  
	
	my $file=shift @_;
	my @array;
	
	open my $fh_partitions, '<', $file or die "Could not open file \"$file\":$!\n";
	     
    while (my $line=<$fh_partitions>){
	
	  chomp $line;	
	  $line=~s/ //g;
	  $line=~s/	//g;
	  
	  #Save coordinates for partition
	  my $coordinate_1;
	  my $coordinate_2;
	
	     if ($line=~m/^(\S+)=(\S+)\-(\S+)\;$/) {	
		   $coordinate_1=$2;
		   $coordinate_2=$3;
	     }
	
	     else {die"Input partition file not in the correct format\n";}
	
	  #Store coordinates of positions for each partition in an array
	  my @positions=($coordinate_1..$coordinate_2);
	  push (@array,\@positions);	
    }
    return \@array;
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
 


