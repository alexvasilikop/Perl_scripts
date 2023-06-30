#!/usr/bin/env perl

use strict;
use warnings;

##prints in the output file the lengths of contigs sorted from longest to shortest
#Usage:perl $0 input_assembly_fasta

my $out_all_lengths = "lengths_assembly.txt";

my $filename = shift @ARGV;

#Reads the fasta assembly in a hash (header -> sequence)
my %headers_scaffolds = &read_fasta_hash($filename);

#returns lenghts of scaffolds from longest to shortest
my @lengths =&get_lengths(values %headers_scaffolds);

open(my $fh_out, ">", $out_all_lengths) or die "Could not open file $out_all_lengths:$!\n";

foreach (@lengths){

	print {$fh_out} "$_\n";

}

close $fh_out;

################################################################################################""
sub read_fasta_hash{

###Reads fasta into a hash
##It takes into account fasta files in interleaved format

open(my $fh, "<", $filename) or die "Could not open file $filename:$!\n";

my @lengths;
my $sequence = "";
my %hash_of_fasta;
my $header;
my $counter;

while (my $line = <$fh>){

	chomp $line;

	if ($line =~ m/>/){

		++$counter;

		if ($counter == 1){

			$header = $line;
			$hash_of_fasta{$line} = "";
			}

	    else{
			$hash_of_fasta{$header} = $sequence;
			$sequence = "";
			$header = $line;
	    	}
	    }

	else{
		$sequence .= $line;
		}
}

$hash_of_fasta{$header} = $sequence;
return  %hash_of_fasta
}

########################################################################
sub get_lengths{

	#Returns a list of lengths of scaffolds in reverse order (i.e., longest to shortest)
	#Input: list of sequences (contigs)
	my @contigs = @_;
	my @list_lengths;

	foreach (@contigs){

		my $len = length($_);
		push(@list_lengths, $len);
	}

	my @list_lengths_sorted = sort { $b <=> $a } @list_lengths;
	return @list_lengths_sorted;
}
