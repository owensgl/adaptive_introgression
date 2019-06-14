#!/bin/perl
use warnings;
use strict;

#This takes a list of output1 files, and processes them into a single file. 
#Doesn't use the logged values;

#my $output_directory = $ARGV[0];

print "gen\tversion\tmean_haldane\tcurrent_optimum\tmean_fitness\tmean_phenotype\tfilename";
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
  }
  unless ($optimum{"test"}{"10100"}){
    my @versions = qw( control test );
    foreach my $version (@versions){
      foreach my $gen (10003..10100){
        print "\n$gen\t$version\tNA\tNA\tNA\tNA\t$filename";
      }
    } 
    next;
  }
  my @versions = qw( control test );
  foreach my $version (@versions){
    foreach my $gen (10003..10100){ 
      my $last_gen = $gen - 1;
      my $p1_pooled_sd = sqrt(((999 * ($phenotype{$version}{$gen}{"p1"}{"sd"}**2)) +  (999 * ($phenotype{$version}{$last_gen}{"p1"}{"sd"}**2))/ 1998));
      my $p1_delta = $phenotype{$version}{$gen}{"p1"}{"mean"} - $phenotype{$version}{$last_gen}{"p1"}{"mean"};
      my $haldane_p1 =  $p1_delta/$p1_pooled_sd;
      
      my $p2_pooled_sd = sqrt(((999 * ($phenotype{$version}{$gen}{"p2"}{"sd"}**2)) +  (999 * ($phenotype{$version}{$last_gen}{"p2"}{"sd"}**2))/ 1998));
      my $p2_delta = $phenotype{$version}{$gen}{"p2"}{"mean"} - $phenotype{$version}{$last_gen}{"p2"}{"mean"};
      my $haldane_p2 =  $p2_delta/$p2_pooled_sd;

      my $mean_haldane = ($haldane_p1 + $haldane_p2)/2;
      
      my $mean_fitness = ($fitness{$version}{$gen}{"p1"} + $fitness{$version}{$gen}{"p2"})/2;
      my $mean_phenotype = ($phenotype{$version}{$gen}{"p1"}{"mean"} + $phenotype{$version}{$gen}{"p2"}{"mean"})/2;
      my $current_optimum = $optimum{$version}{$gen};
      
      print "\n$gen\t$version\t$mean_haldane\t$current_optimum\t$mean_fitness\t$mean_phenotype\t$filename";
    }
  }


}
