#!/usr/bin/perl
use warnings;
use strict;

my $filename = $ARGV[0];
my $cap = $ARGV[1]; #sets an optional cap on number to download for debugging


open(FH, '<', $filename) or die $!;

my $otu;
my $link;
my $count;

while(<FH>){
	#check cap
	if($count > $cap){
		exit;
	}
	my @line = split(/\t/, $_);
	my $otu = $line[0]."_".$line[1]."__".$line[2];
	my $link = $line[3];
	chomp $link;

	my $command = "gdown --id ".$link." -O ./pep/".$otu.".fa";
#	my $command = "wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=".$link."' -O ./pep/".$otu.".pep";
	system($command);
#	print $command."\n";
	$count++;

}

close(FH);
exit;





