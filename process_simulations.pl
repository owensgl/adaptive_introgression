#!/bin/perl
use warnings;
use strict;
#This script takes the output of the simulation scripts and outputs it to a summary file. It combines multiple files. Pipe in a list of simulation outputs eg. ls | grep output_ | script.pl > summary.txt

my @parameters;
open PAR, "parameter_file.txt";
while(<PAR>){
  chomp;
  @parameters = split(/\t/,$_);
}
close PAR;

print "seed\ttreatment\tout_type\tphase\tburn_in_gens\tp1_home_percent\tp2_home_percent\tfit_dif\trep";
foreach my $par (@parameters){
  print "\t$par";
}
my $cmd = "ls output/";
my @list = `$cmd`;
foreach my $filename (@list){  
  chomp($filename);
  open(FILE, "zcat output/$filename |");
  my @settings = split(/_/,$filename);
  while(my $sim_line=<FILE>){
    chomp($sim_line);
    my @a = split(/\t/,$sim_line);
    if ($a[2] eq "OUT1"){
      print "\n$sim_line";
    }else{
      next;
    }
    foreach my $i (1..$#settings){
      my $setting = $settings[$i];
      $setting =~ s/.txt.gz//g;
      print "\t$setting";
    }
  }
}
