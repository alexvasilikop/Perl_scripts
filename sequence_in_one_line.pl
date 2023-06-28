#!/usr/bin/env perl

use strict;
use warnings;


system "ls *.fas > list_of_fasta_names.txt";
unless (-e "outfiles") {system "mkdir outfiles";}
my $fastafiles = "list_of_fasta_names.txt";
open (my$fh, '<', $fastafiles) or die"Cannot open file \"$fastafiles\":$!\n";	

my @fasta_names= <$fh>;
chomp @fasta_names;
close $fh;
my $header;

foreach my $file (@fasta_names) {
	my %headers_sequences;
	open (my$fh1, '<', $file) or die"Cannot open file \"$file\":$!\n";
	while (my $line=<$fh1>) {
		chomp $line;
		if ($line=~ m/>/) {
		  $header=$line;
		 }
		else { $headers_sequences{$header}.=$line;}
	}
	close $fh1;
	my $outfile= $file;	
	my $outpath= "/home/alex/Documents/ALEX/Master thesis/Methods/transcriptomes/101_species/1K_TSA_accepted_e3_SCIENCE_101_species/outfiles//";
	my $out="$outpath$outfile";
	open (my $fh_out, '>', $out) or die"Cannot open file \"$out\":$!\n";
	foreach my $key (keys %headers_sequences){
		print {$fh_out} "$key\n$headers_sequences{$key}\n";
	}
	close $fh_out;
	
	
}

