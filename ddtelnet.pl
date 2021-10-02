#!/usr/bin/perl
use strict;
use warnings;

use bignum qw/hex/;
use Net::Telnet ();
use Data::Dumper;

my $t = new Net::Telnet (Timeout => 30,
											Telnetmode => 0,
											Binmode => 1,
#											Dump_log => "vgz.log",
                      Prompt => '/ $/');

#$|++;

open FILE, ">:raw", "/mnt/hdd/smooker/sda.img";

my $host="192.168.77.102";
my $username="admin";
my $passwd="admin";
my @lines;

$t->open($host);

$t->login($username, $passwd);
$t->cmd("su");
$t->cmd("admin");
$t->prompt('/ #/');
#1953514584  1k blocks
#$t->telnetmode(0);

for (my $i=0;$i<=1953514584/1024;$i++) {
	my @lines;
	my $bs=512*1;
	my $skip=$i*$bs;
  print "SKIP:$skip\n";
	@lines = $t->cmd(String => "dd if=/dev/sda bs=$bs skip=$skip count=1 | hexdump -v -e '\"%08.8_ax  \" 16/1 \"%02x \" \"\n\"' ", Cmd_remove_mode => 0, Prompt => '/~ #/');

	chomp @lines;
#	print @lines;
#~SKIP:13312
#1+0 records in
#1+0 records out
#512 bytes (512B) copied, 0.000119 seconds, 4.1MB/s
#00000000  ab fd e9 21 78 a4 ec 04  fe 74 2f 7e 09 26 24 df  |...!x....t/~.&$.|
#00000010  90 8d 1f b0 35 7b e1 9a  56 4a 74 5e c8 d1 3f 4a  |....5{..VJt^..?J|
#00000020  69 0e bf e5 d9 ff 46 13  bd ff bd eb b2 39 f1 43  |i.....F......9.C|
  my $addr_w_offset=sprintf("%08x", $skip);
#	print FILE "SK: $skip\n";
	chomp $addr_w_offset;

#  print FILE ( "OFF: $addr_w_offset\n");

#	print Dumper(@lines);
#	exit();	

	my $cnt=0;
	foreach my $line (@lines) {
		$cnt++;
#	  chomp $line;
#		print "$line\n";

	  if ( ( $line =~ /^1\+0\ records\ in$/ ) & ( $cnt == 1 ) ) {
    	print "$line\n";
		#	print "BRAVOO\n";
		  next;	
		}
    if ( ( $line =~ /^1\+0\ records\ out$/ ) & ( $cnt == 2 ) ) {
      print "$line\n";
    # print "BRAVOO\n";
      next;
    }
    if ( ( $line =~ /^512\ bytes\ \(512B\)\ copied,\ \d+.\d+\ seconds,\ \d+.\d+MB\/s$/ ) & ( $cnt == 3 ) ) {
      print "$line\n";
    # print "BRAVOO\n";
      next;
    }
    if ( ( $line =~ m/^([0-9,a-f,A-F]{8}){1}\s+((?:\s+[0-9,a-f,A-F]{2})+)+/ ) & ($cnt >= 4) ) {
		  chomp $addr_w_offset;
		  chomp $line; 
#			print FILE ">".$line;
#			print FILE $addr_w_offset;
#		  print FILE $1."\n";
		  my $hex = $2;
		  $hex =~ s/\s+//g;
	    my $bin = pack 'H*', $hex;
#      print FILE sprintf("%08x ", ( hex($addr_w_offset) + hex($1) ) )." $2\n";
			print FILE $bin;
#			$addr_w_offset+=0x10;	
#     print "BRAVOO\n";
      next;
    }
    if (  $line =~ m/^([0-9,a-f,A-F]{8})/ )  {
      print "$1 END $cnt\n";
		  if ($cnt != $bs/16+5) {
				die("vgz");
			}
#     print "BRAVOO\n";
      next;
    }
	  
	}
#  sleep(1)
}
close FILE;
$t->close($host);