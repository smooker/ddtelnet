#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

open FILEIN, "<", "/mnt/hdd/smooker/sda.img";
open FILEOUT, ">:raw", "/mnt/hdd/smooker/sda.bin";

while (<FILEIN>) {
#	print $_;
  if (  m/^([0-9,a-f,A-F]{8}){1}\s+((?:\s{1}[0-9,a-f,A-F]{2})+)+/ )   {
		chomp $2;
#    print "$2\n";
	  my $bin = pack 'H*', $2;
		print FILEOUT $bin;
#		my @bytes = split(" ", $2);
#		print Dumper(@bytes);
#		foreach my $byte (@bytes) {
#		  chomp $byte;
#			print $byte."\n";
#			print FILEOUT (chr(hex($byte)));
			#print $byte;
			#print (chr(hex($byte)));
#		}
	}	
}
close FILEIN;
close FILEOUT;