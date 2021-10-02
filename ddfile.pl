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

my $remotefile = $ARGV[0];
my $localfile = $ARGV[1];
#exit;

open FILE, ">:raw", $localfile;

my $host="192.168.77.102";
my $username="admin";
my $passwd="admin";
my @lines;

$t->open($host);
$t->max_buffer_length( 1024*1024*1024 );
$t->login($username, $passwd);
$t->cmd("su");
$t->cmd("admin");
$t->prompt('/ #/');

	my $bs=512*1;
	@lines = $t->cmd(String => "dd if=$remotefile | hexdump -v -e '\"%08.8_ax  \" 16/1 \"%02x \" \"\n\"' ", Cmd_remove_mode => 0, Prompt => '/~ #/');

	my $cnt=0;
	foreach my $line (@lines) {
		$cnt++;
	  chomp $line;
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
    if ( ( $line =~ m/^([0-9,a-f,A-F]{8}){1}\s+((?:\s+[0-9,a-f,A-F]{2})+)+/ ) ) {
			my $addr = $1;
		  my $hex = $2;
		  $hex =~ s/\s+//g;
			print $addr."  ".$hex."\n";
	    my $bin = pack 'H*', $hex;
#      print FILE sprintf("%08x ", ( hex($addr_w_offset) + hex($1) ) )." $2\n";
			print FILE $bin;
      next;
    }
	}
close FILE;
$t->close($host);