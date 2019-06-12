#!/bin/perl
use strict;
use warnings;
#This script takes the OUT5 output (a big list of mutations per sample), and turns it into the long format

my %genotypes;
my %loci;
my $mut_info_file = $ARGV[0];
my $mut_fit_file = $ARGV[1];
my %muts;
my %mut_strength;
my %mut_freq;
my %mut_pop;
my %sample_fit;
open MUT, $mut_info_file; #OUT3
while(<MUT>){
  chomp;
  my @a = split(/\t/,$_);
  my $type = $a[2];
  if ($type ne "M1"){
#print STDERR "Skipping $type\n";
   next;}
  my $strength = $a[9];
  my $loci = $a[6];
  my $freq = $a[8];
  my $mut_popID = $a[7];
  my $gen = $a[3];
  my $pop = $a[4];
  $pop =~ s/p//;
  $muts{$loci} = $strength;
  $mut_pop{$loci} = $mut_popID;
  $mut_freq{$gen}{$pop}{$loci} = $freq;
  $mut_strength{$loci} = $strength;
  
}
close MUT;

open FIT, $mut_fit_file; #OUT4
while(<FIT>){
  chomp;
  my @a = split(/\t/,$_);
  $sample_fit{$a[2]}{$a[3]}{$a[4]} = $a[5];
}
close FIT; 


while(<STDIN>){
  chomp;
  my @a = split(/\t/,$_);
  my $gen = $a[2];
  my $pop = $a[3];
  my $id = $a[4];
  foreach my $i (5..$#a){
    unless($muts{$a[$i]}){next;}
    unless($loci{$a[$i]}){
      $loci{$a[$i]}++;
    }
    $genotypes{$gen}{$pop}{$id}{$a[$i]}++;
    
  }
}

print "gen\tpop\tid\tmut_ID\tmut_sel\tmut_freq\tmut_popID\tfitness\tgeno";
foreach my $gen (sort keys %genotypes){
  if ($gen <= 10001){next;}
  foreach my $pop (sort keys %{$genotypes{$gen}}){
    foreach my $id (sort keys %{$genotypes{$gen}{$pop}}){
      foreach my $loci (sort keys %loci){
	unless($mut_freq{$gen}{$pop}{$loci}){
	  $mut_freq{$gen}{$pop}{$loci} = 0;
	}
        if ($genotypes{$gen}{$pop}{$id}{$loci}){
          print "\n$gen\t$pop\t$id\t$loci\t$mut_strength{$loci}\t$mut_freq{$gen}{$pop}{$loci}\t$mut_pop{$loci}\t";
	  print "$sample_fit{$gen}{$pop}{$id}\t$genotypes{$gen}{$pop}{$id}{$loci}";
        }else{
          print "\n$gen\t$pop\t$id\t$loci\t$mut_strength{$loci}\t$mut_freq{$gen}{$pop}{$loci}\t$mut_pop{$loci}\t";
          print "$sample_fit{$gen}{$pop}{$id}\t0";
        }
      }
    }
  }
}

