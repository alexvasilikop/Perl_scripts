#!/usr/bin/env perl

###########################################################################################################################################################
#Extract rates for partitions from iqtree output file. Calculate median quartile 1 and 3 for collection of rate values
###########################################################################################################################################################

use strict;
use warnings;

my %hash_of_rates=();
my %hash_of_ids=();

#Extract rates
my @fasta_files=glob "*.fas";
chomp @fasta_files;

my $rates_file=shift @ARGV;
my $ids_file=shift @ARGV;

open my $fh, '<', $rates_file or die"Could not open file \"$rates_file\":$!\n";
open my $fh_2, '<', $ids_file or die"Could not open file \"$ids_file\":$!\n";

#read rate file from iqtree                     
while(my $line=<$fh>){
	
	chomp $line;
	my @elements=split (" ", $line);
	$elements[0]=~s/ //g;
	$elements[2]=~s/ //g;

	$hash_of_rates{$elements[0]}=$elements[2];
}

close $fh;

#read ids                 
while(my $line=<$fh_2>){
	
	chomp $line;
	my @elements=split (" ", $line);
	$elements[0]=~s/ //g;
	$elements[1]=~s/ //g;

	$hash_of_ids{$elements[0]}=$elements[1];
}

close $fh_2;

my @values=values %hash_of_rates;

my @sorted_values=sort { $a <=> $b } @values;
my $no=scalar @sorted_values;

my @lower_half;
my @upper_half;

#Calculate median and quartiles of rate values for the dataset
my $median;
my $Q1;
my $Q3;

if (@sorted_values%2==0) {
		
		$median=($sorted_values[(@sorted_values/2)-1]+$sorted_values[(@sorted_values/2)])/2;
		
		#calculate Q1, Q3 for even number of rates
        for(my $i=0; $i<=(@sorted_values-1); ++$i){
			
			if ($i<=((@sorted_values/2)-1)){
			push (@lower_half, $sorted_values[$i])
		    }
		
            else{
			push (@upper_half, $sorted_values[$i])
		    }
	    }
	    
	    $Q1= $lower_half[(@lower_half/2)+0.5];
	    $Q3= $upper_half[(@upper_half/2)+0.5];
	    
} 
	
else{
		$median= $sorted_values[(@sorted_values/2)+0.5];
		
		#print "$median\n";
		#calculate Q1, Q3 for odd number of rates
		for(my $i=0; $i<=(@sorted_values-1); ++$i){
			
			if ($i<=((@sorted_values/2)-1)){
			push (@lower_half, $sorted_values[$i])
		    }
		
            else{	
			push (@upper_half, $sorted_values[$i])
		    }
	    }
	    
	    #calculate Q1, Q3 for odd number of rates
	    $Q1=$median=($lower_half[(@lower_half/2)-1]+$lower_half[@lower_half/2])/2;
	    $Q3=($upper_half[(@upper_half/2)-1]+$upper_half[@upper_half/2])/2;
}

print scalar @lower_half, "\n";
print scalar @upper_half, "\n";

print "@lower_half", "\n";
print "@upper_half", "\n";


print "$Q1", "\n";
print "$Q3", "\n";

my $outlier_threshold2=$Q3+(($Q3-$Q1)*1.5);
my $outlier_threshold1=$Q1-(($Q3-$Q1)*1.5);

print "$outlier_threshold1", "\n";
print "$outlier_threshold2", "\n";

my %hash_new;

foreach (sort (keys %hash_of_rates)){
	
	if (exists ($hash_of_ids{$_})) {
		
		next unless -f "$hash_of_ids{$_}.fas";
		system"rm $hash_of_ids{$_}.fas" if $hash_of_rates{$_}>$outlier_threshold2;
		system"rm $hash_of_ids{$_}.fas" if $hash_of_rates{$_}<$outlier_threshold1;
	}
}
		
		

