#!/usr/bin/env perl

use strict;
use warnings;

#####################################################################################################################
#Identify different splice variants/isoforms of the same gene in complete protein sets for one or more species.
#Find candidate duplicate sequences/splice variants by first blasting all of them against the same species' proteome 
#(e-value 1e-200). Use max allowed aa window size (i.e 7 during blastp search). Evaluate the results -> distinguish
#between duplicates, isoforms, and exclude comparisons between the same sequence.
#####################################################################################################################
#Requirements: requires the installation of blast+
#####################################################################################################################
#copyright 2017 by A.Vasilikopoulos

#create array with names of proteomes
my @protein_files=glob"*.fa";

foreach (@protein_files){

##make blast db from input file. Parse seqid for fasta files if set
system "makeblastdb -in $_ -dbtype prot -out $_.db";

##blast seqs against db one by one.Blast each file against the database
system "blastp -query $_ -db $_.db -word_size 7 -out result_blastp_$_.txt -evalue 1e-200 -outfmt \"6 qseqid sseqid evalue qseq sseq\" ";

#delete blast database for the species/proteome
unlink "$_.db.phr";
unlink "$_.db.pin";
unlink "$_.db.psq";

}

my @blast_out=glob "*.txt";

#loop through the blast output file
foreach (@blast_out){
	
	#create duplicate seqs file and potential isoform/splice variant files for each proteome
	my $filtered= "$_.filtered";
	my $duplicate="$_.duplicate";
	
	open my $fh, '<', $_ or die"Could not open file \"$_\":$!\n";
	open my $fh_out, '>', "$_.filtered" or die"Could not open file \"$_.filtered\":$!\n";
    open my $fh_out_2, '>', "$_.duplicate" or die"Could not open file \"$_.duplicate\":$!\n";

	#loop through each candidate pair
	while (my $pair=<$fh>) {
		
		chomp $pair;
		my @array=split(" ", $pair);
		
		#if query and subject have the same id skip
		next if $array[0] eq $array[1];
		
		#find duplicate sequences with different seq ids
		if($array[3] eq $array[4]) {print {$fh_out_2} $pair, "\n"; next;}
		
		#Employ a window size comparison approach. Take a window size of 40 aa in the query from position0 compare with all 
		#possible windowsizes (with length of 50 aa) in subject. If total no. of matches after all steps >70 -> isoform proteins/splice variants
		
		#cont lengths, specify windowsize
		my $counter=0;
		my $length_query=length $array[3];
		my $length_subject=length $array[4];
		my $windowsize=50;
		
		#apply comparisons
		for (my $position=0; ($position+1)<=$length_query-$windowsize; ++$position) {
			
			my $seq=substr($array[3], 0, $windowsize);
                   
                   #take selected window of query and compare it with the subject
                   for (my $position=0; ($position+1)<=$length_subject-$windowsize; ++$position) {
					   
					   my $seq2=substr($array[4], 0, $windowsize);
					   if ($seq eq $seq2){++$counter;}
				   }
		}
		
		#print splice variants/isoforms
		if ($counter>120) {print {$fh_out} $pair, "\n";}
	}
	close $fh;
	close $fh_out;
	close $fh_out_2;
}
		
