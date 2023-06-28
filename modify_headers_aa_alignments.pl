#!/usr/bin/env perl

use strict;
use warnings;

my @files=glob"*.fas";
chomp @files;

foreach (@files){
	
	my $out="$_"."new_headers";
	
	open my $fh, "<", $_ or die;
	open my $fh_out, ">", $out or die;
	
	while(my $line=<$fh>){
		
		chomp $line;
		
		
		if ($line=~m/^>.+/){
			
			$line=~s/>//;
			$line=~s/ //g;
			$line=~s/	//g;
			
		my @array=split("", $line);
		print {$fh_out} ">";
		
		if (scalar @array<150){print {$fh_out} "$line\n";}
		else{
		for (my $i=0; $i<149;$i+=1){
			print {$fh_out} $array[$i];
		}
		print {$fh_out} "\n";
	    }
     }
	   else {print {$fh_out} "$line\n";}
	   
    }
    close $fh;
    close $fh_out;
}
			
		
			
