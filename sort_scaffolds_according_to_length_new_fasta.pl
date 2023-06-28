#!/usr/bin/env perl 

use strict;
use warnings;
use Getopt::Long;

#Sorts input assembly file according to the lengths of scaffolds (from longest to shortest). Should be in fasta format
#Usage: perl $0 -in assembly_file.fa -out out_assembly.fa

my $assembly_file;
my $out_assembly_file;

GetOptions ("in=s"   => \$assembly_file,      # string
            "out=s"  => \$out_assembly_file) or die"Error in command line arguments:$!\n";

open(my $fh_out, ">", $out_assembly_file) or die"Could not open file $out_assembly_file:$!\n";

my $scaffold_counter = 0;
my $genome_size=0;

# Read assembly fasta and return hash of arrays (arrays with 2 elements) -> $hash{contig} = (contig_sequence, length_of_sequence)
my %hash_head_seq_len = %{read_assembly_file($assembly_file)};

foreach my $scaffold (sort { ${$hash_head_seq_len{$b}}[1] <=> ${$hash_head_seq_len{$a}}[1] } keys %hash_head_seq_len) {

	my @seq_len = @{$hash_head_seq_len{$scaffold}};

	print {$fh_out} $scaffold."\n".$seq_len[0]."\n";

	$genome_size += $seq_len[1];
	++$scaffold_counter;
}

close $fh_out;

print "Genome size:\n$genome_size\n";
print "Number of scaffolds:\n$scaffold_counter\n";

######################################################################################################################
sub read_assembly_file {

	my $assembly = shift @_;

	open(my $fh_in, "<", $assembly) or die"Could not open file $assembly:$!\n";

	my $header ="";
	my %seq_and_head;
	my $length_scaffold = 0;
	my $sequence = "";
	my $line_counter =0;

	while (my $line = <$fh_in>){

		chomp $line;

		if ($line =~ m/^>/ and $line_counter==0){

			$header=$line;
			++$line_counter;
		}

		elsif ($line =~ m/^>/){

			$length_scaffold =length($sequence);
			my $length_scaffold_and_sequence = [$sequence, $length_scaffold]; #ref. to anonymous array
			$seq_and_head{$header}=$length_scaffold_and_sequence;

			$header=$line;
			$seq_and_head{$line}=();
			$sequence = "";
		}

		else{
			$line = uc $line;
			$sequence.=$line;
		}
	}

	#Add sequence and its length for the last scaffold
	$length_scaffold =length($sequence);
	my $length_scaffold_and_sequence = [$sequence, $length_scaffold];
	$seq_and_head{$header}=$length_scaffold_and_sequence;
	close $fh_in;

	return \%seq_and_head;
}