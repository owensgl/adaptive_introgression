#!/bin/perl
use warnings;
use strict;

#This takes a list of output2 files, and processes them into a single file. 

print "version\tpurity_change\tfit_change\tfilename";
while(my $filename = <STDIN>){
  chomp($filename);
  unless ($filename =~ m/out2.txt.gz/){next};
  my %hash;
  open(IN, "gunzip -c $filename |") || die "can’t open pipe to $filename";
  while(my $line = <IN>){
    chomp($line);
    if ($line =~ m/output/){next;}
    my @a = split(/\t/,$line);
    $hash{$a[1]}{"p1"} = $a[2];
    $hash{$a[1]}{"p2"} = $a[3];
    $hash{$a[1]}{"fit"} = $a[4];
  }
  unless($hash{"test"}{"p1"}){next;}
  my $purity_start = ($hash{"burn_in"}{"p1"} + $hash{"burn_in"}{"p1"}) /2;
  my $purity_end_control = ($hash{"control"}{"p1"} + $hash{"control"}{"p1"}) /2;
  my $purity_end_test = ($hash{"test"}{"p1"} + $hash{"test"}{"p1"}) /2;
  my $purity_change_control = $purity_start - $purity_end_control;
  my $purity_change_test = $purity_start - $purity_end_test;

  my $fit_change_control = $hash{"burn_in"}{"fit"} - $hash{"control"}{"fit"};
  my $fit_change_test = $hash{"burn_in"}{"fit"} - $hash{"test"}{"fit"};
  
  print "\ncontrol\t$purity_change_control\t$fit_change_control\t$filename";
  print "\ntest\t$purity_change_test\t$fit_change_test\t$filename";

}
