#!/usr/bin/env perl 

#Recoding of 3rd positions only in RY coding (input in fasta format)

use strict;
use warnings;

my $file=shift @ARGV;
open my $fh, '<', $file or die;
my %hash;

while (my $line=<$fh>){

   chomp $line;
   
   if ($line=~m/^>/){
   
   print $line , "\n";
   
   }

   else {
	   
	   my $a;
	   
	   for (my $i=0;$i<length $line;$i=$i+1){
		 
	   $a=substr($line,$i,1);  
	   
	   if (($i+1)%3==0){
	   $a=~s/A/R/i;
	   $a=~s/G/R/i;
	   $a=~s/C/Y/i;
	   $a=~s/T/Y/i;
	   print $a;
	   }
	   
	   else{print $a;}
       }
	   
      }
      print "\n";
  }


