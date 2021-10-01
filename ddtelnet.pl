#!/usr/bin/perl
use strict;
use warnings;

use Net::Telnet ();
my $t = new Net::Telnet (Timeout => 3,
											Telnetmode => 0,
											Binmode => 1,
#											Dump_log => "vgz.log",
                      Prompt => '/ $/');

$|++;

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
	my $bs=512*8;
	my $skip=$i*$bs;
  print "SKIP:$skip\n";
	@lines = $t->cmd(String => "dd if=/dev/sda bs=$bs skip=$skip count=1 | hexdump -v -C", Cmd_remove_mode => 0, Prompt => '/~ #/');
#	print @lines;
#~SKIP:13312
#1+0 records in
#1+0 records out
#512 bytes (512B) copied, 0.000119 seconds, 4.1MB/s
#00000000  ab fd e9 21 78 a4 ec 04  fe 74 2f 7e 09 26 24 df  |...!x....t/~.&$.|
#00000010  90 8d 1f b0 35 7b e1 9a  56 4a 74 5e c8 d1 3f 4a  |....5{..VJt^..?J|
#00000020  69 0e bf e5 d9 ff 46 13  bd ff bd eb b2 39 f1 43  |i.....F......9.C|
	my $cnt=0;
	foreach my $line (@lines) {
		$cnt++;
	  chomp $line;
		print "$line\n";

	  if ( $line =~ /^1\+0\ records\ in$/ & $cnt == 1 ) {
    	print "$line\n";
		#	print "BRAVOO\n";
		  next;	
		}
    if ( $line =~ /^1\+0\ records\ out$/ & $cnt == 2 ) {
      print "$line\n";
    # print "BRAVOO\n";
      next;
    }
    if ( $line =~ /^512\ bytes\ \(512B\)\ copied,\ \d+.\d+\ seconds,\ \d+.\d+MB\/s$/ & $cnt == 3 ) {
      print "$line\n";
    # print "BRAVOO\n";
      next;
    }
    if ( ( $line =~ m/^([0-9,a-f,A-F]{8}){1}\s+((?:\s+[0-9,a-f,A-F]{2})+)+/ ) & ($cnt >= 4) ) {
      print "$1 $2\n";
#     print "BRAVOO\n";
      next;
    }
    if (  $line =~ m/^([0-9,a-f,A-F]{8})/ )  {
      print "$1 END $cnt\n";
		  if ($cnt != 261) {
				die("vgz");
			}
#     print "BRAVOO\n";
      next;
    }
	  
	}
#  sleep(1)
}
$t->close($host);