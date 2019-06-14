#!/bin/perl
use warnings;
use strict;

#This takes a list of output1 files, and processes them into a single file. 
#Doesn't use the logged values;

#my $output_directory = $ARGV[0];

print "gen\tversion\toptimum\tp1mean\tp2mean\tfilename";
while(my $filename = <STDIN>){
  chomp($filename);
  unless($filename =~ m/out1.txt.gz/){next;}
  my %fitness;
  my %phenotype;
  my %optimum;
  open(IN, "gunzip -c $filename |") || die "can’t open pipe to $filename";
  while(my $line = <IN>){
    chomp($line);
    if ($line =~ m/output/){next;}
    my @a = split(/\t/,$line);
    my $version = $a[1];
    my $gen = $a[2];
    if ($gen <= 10001){next;}
    my $optimum = $a[3];
    my $p1fit = $a[4];
    my $p1mean = $a[5];
    my $p1sd = $a[6];
    my $p2fit = $a[7];
    my $p2mean = $a[8];
    my $p2sd = $a[9];
    $optimum{$version}{$gen} = $optimum;
    $fitness{$version}{$gen}{"p1"} = $p1fit;
    $fitness{$version}{$gen}{"p2"} = $p2fit;
    $phenotype{$version}{$gen}{"p1"}{"mean"} = $p1mean;
    $phenotype{$version}{$gen}{"p2"}{"mean"} = $p2mean;
    $phenotype{$version}{$gen}{"p1"}{"sd"} = $p1sd;
    $phenotype{$version}{$gen}{"p2"}{"sd"} = $p2sd;
    if ($version eq "test"){
      print "\n$gen\t$version\t$optimum\t$p1mean\t$p2mean\t$filename";
    }
  }
}
