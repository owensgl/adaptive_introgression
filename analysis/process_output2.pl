#!/bin/perl
use warnings;
use strict;
use POSIX;
#This takes a list of output2 files, and processes them into a single file. 

#my $output_directory = $ARGV[0];

my @parameters;
open(PAR, "../../../parameter_file.txt");
while (my $line = <PAR>){
  @parameters = split(/\t/,$line);
}

close PAR;
my %div_hash;
my %bdm_hash;
my %test_hash;
while(my $filename = <STDIN>){
  chomp($filename);
  my $id = $filename;
  $id =~ s/_out.*.txt.gz//g;
  if ($filename =~ m/out2.txt.gz/){
    open(IN, "gunzip -c $filename |") || die "can’t open pipe to $filename";
    while(my $line = <IN>){
      chomp($line);
      if ($line =~ m/output/){next;}
      my @a = split(/\t/,$line);
      my $version = $a[1];
      $div_hash{$id}{$version}{"p1_neutral"} = $a[2];
      $div_hash{$id}{$version}{"p2_neutral"} = $a[3];
      $div_hash{$id}{$version}{"p1_count"} = $a[4];
      $div_hash{$id}{$version}{"p2_count"} = $a[5];
    }
    close IN;
  }elsif ($filename =~ m/out6.txt.gz/){
    my %bdm_hash;
    open(IN, "gunzip -c $filename |") || die "can’t open pipe to $filename";
    while(my $line = <IN>){
      chomp($line);
      if ($line =~ m/output/){next;}
      my @a = split(/\t/,$line);
      my $version = $a[1];
      my $pop = $a[2];
      my $pair = $a[3];
      my $state = $a[4]; #Used as a proxy for site 1 vs site 2
      my $freq = $a[6];
      my $site;
      #Only record derived allele frequency
      if ($state eq "noninter"){
        my $new_freq = 1- $freq;
        $freq = $new_freq;
        $state = "s1";
      }else{
	$state = "s2";
      }
      $bdm_hash{$id}{$version}{$pair}{$pop}{$state} = $freq;
$test_hash{$id}{$version}{$pair}{$pop}{$state} = $freq;
    }
  }
}
    
my @versions =qw(burn test control);
my @pops = qw(p1 p2);
print "filename\tstat\ttype\tversion\tscore";
foreach my $id ( sort keys %div_hash){
  #Figure out how many divergently selected alleles and what the s_ri value is from the title
  my @ids = split(/_/,$id);
  my $rimax;
  my $totaldivbdmn;
  my $proportionbdm;
  foreach my $i (0..$#parameters){
    if ($parameters[$i] eq "totaldivbdmn"){
      $totaldivbdmn = $ids[$i+2];
    }elsif ($parameters[$i] eq "rimax"){
      $rimax = $ids[$i+2];
    }elsif ($parameters[$i] eq "proportionbdm"){
      $proportionbdm = $ids[$i+2];
    }
  }
  my $total_div_n = floor($totaldivbdmn * (1 - $proportionbdm));
  my $total_bdm_n = floor($totaldivbdmn * $proportionbdm);

  #Purity changes 
  if (exists($div_hash{$id}{"test"}{"p1_neutral"})){
    #First pull out purity changes
    my $purity_start = ($div_hash{$id}{"burn"}{"p1_neutral"} + $div_hash{$id}{"burn"}{"p2_neutral"}) /2;
    my $purity_end_control = ($div_hash{$id}{"control"}{"p1_neutral"} + $div_hash{$id}{"control"}{"p2_neutral"}) /2;
    my $purity_end_test = ($div_hash{$id}{"test"}{"p1_neutral"} + $div_hash{$id}{"test"}{"p2_neutral"}) /2;
    print "\n$id\tpurity\tNA\tstart\t$purity_start";
    print "\n$id\tpurity\tNA\tcontrol\t$purity_end_control";
    print "\n$id\tpurity\tNA\ttest\t$purity_end_test";
    #Next get counts of divergently selected sites
    my $home_count_start = (($total_div_n - $div_hash{$id}{"burn"}{"p1_count"}) + ($total_div_n - $div_hash{$id}{"burn"}{"p2_count"})) /2;
    my $away_count_start = (($div_hash{$id}{"burn"}{"p1_count"}) + ($div_hash{$id}{"burn"}{"p2_count"})) /2;
    my $home_count_end_control = (($total_div_n - $div_hash{$id}{"control"}{"p1_count"}) + ($total_div_n - $div_hash{$id}{"control"}{"p2_count"})) /2;
    my $away_count_end_control = (($div_hash{$id}{"control"}{"p1_count"}) + ($div_hash{$id}{"control"}{"p2_count"})) /2;
    my $home_count_end_test = (($total_div_n - $div_hash{$id}{"test"}{"p1_count"}) + ($total_div_n - $div_hash{$id}{"test"}{"p2_count"})) /2;
    my $away_count_end_test = (($div_hash{$id}{"test"}{"p1_count"}) + ($div_hash{$id}{"test"}{"p2_count"})) /2;
    print "\n$id\tdiv_count\thome\tstart\t$home_count_start";
    print "\n$id\tdiv_count\taway\tstart\t$away_count_start";
    print "\n$id\tdiv_count\thome\tcontrol\t$home_count_end_control";
    print "\n$id\tdiv_count\taway\tcontrol\t$away_count_end_control";
    print "\n$id\tdiv_count\thome\ttest\t$home_count_end_test";
    print "\n$id\tdiv_count\taway\ttest\t$away_count_end_test";
    #Count the number of expected number of bdms
    my %bdm_home;
    my %bdm_away;
    foreach my $version (@versions){
      foreach my $pair (sort keys %{$test_hash{$id}{$version}}){
	#For expected fitness with home cross
	foreach my $pop (@pops){
          my $home_count_AABB = (2 * ($test_hash{$id}{$version}{$pair}{$pop}{"s1"}**2) 
		* ($test_hash{$id}{$version}{$pair}{$pop}{"s2"}**2) );
    	  my $home_count_AaBB = (1.5 * 2 * ($test_hash{$id}{$version}{$pair}{$pop}{"s1"} 
		* (1- $test_hash{$id}{$version}{$pair}{$pop}{"s1"})) 
		* ($test_hash{$id}{$version}{$pair}{$pop}{"s2"}**2));
	  my $home_count_AABb = (1.5 * 2 * ($test_hash{$id}{$version}{$pair}{$pop}{"s2"} 
		* (1- $test_hash{$id}{$version}{$pair}{$pop}{"s2"})) 
		* ($test_hash{$id}{$version}{$pair}{$pop}{"s1"}**2));
	  my $home_count_AaBb = ( 2 * ($test_hash{$id}{$version}{$pair}{$pop}{"s2"} 
		* (1- $test_hash{$id}{$version}{$pair}{$pop}{"s2"})) * 2 
		* ($test_hash{$id}{$version}{$pair}{$pop}{"s1"} 
		* (1- $test_hash{$id}{$version}{$pair}{$pop}{"s1"})));
	  my $home_count = ($home_count_AABB + $home_count_AaBB + $home_count_AABb + $home_count_AaBb )/2;
	  $bdm_home{$version}+= $home_count;
        }
      	#For expected fitness with away cross
     	#s1 = A, 1- s1 = a, s2 = B, 1-s2 = b
      	my $away_count_AABB =$test_hash{$id}{$version}{$pair}{"p1"}{"s1"} * $test_hash{$id}{$version}{$pair}{"p2"}{"s1"} 
		* $test_hash{$id}{$version}{$pair}{"p1"}{"s2"} * $test_hash{$id}{$version}{$pair}{"p2"}{"s2"};
	$away_count_AABB*=2; 
      	my $away_count_AaBB = (($test_hash{$id}{$version}{$pair}{"p1"}{"s1"} * (1- $test_hash{$id}{$version}{$pair}{"p2"}{"s1"})) 
		+ ((1- $test_hash{$id}{$version}{$pair}{"p1"}{"s1"}) * $test_hash{$id}{$version}{$pair}{"p2"}{"s1"})) 
		* ($test_hash{$id}{$version}{$pair}{"p1"}{"s2"} * $test_hash{$id}{$version}{$pair}{"p2"}{"s2"});
        $away_count_AaBB*=1.5;
	my $away_count_AABb = (($test_hash{$id}{$version}{$pair}{"p1"}{"s2"} * (1- $test_hash{$id}{$version}{$pair}{"p2"}{"s2"}))
                + ((1- $test_hash{$id}{$version}{$pair}{"p1"}{"s2"}) * $test_hash{$id}{$version}{$pair}{"p2"}{"s2"}))
                * ($test_hash{$id}{$version}{$pair}{"p1"}{"s1"} * $test_hash{$id}{$version}{$pair}{"p2"}{"s1"});
	$away_count_AABb*=1.5;
	my $away_count_AaBb = (($test_hash{$id}{$version}{$pair}{"p1"}{"s1"} * (1- $test_hash{$id}{$version}{$pair}{"p2"}{"s1"}))
                + ((1- $test_hash{$id}{$version}{$pair}{"p1"}{"s1"}) * $test_hash{$id}{$version}{$pair}{"p2"}{"s1"}))
		* (($test_hash{$id}{$version}{$pair}{"p1"}{"s2"} * (1- $test_hash{$id}{$version}{$pair}{"p2"}{"s2"}))
                + ((1- $test_hash{$id}{$version}{$pair}{"p1"}{"s2"}) * $test_hash{$id}{$version}{$pair}{"p2"}{"s2"}));
	my $away_count = ($away_count_AABB + $away_count_AaBB + $away_count_AABb + $away_count_AaBb );
#print STDERR "$away_count_AABB\t$away_count_AABb\t$away_count_AaBB\t$away_count_AaBb\n";
	$bdm_away{$version} += $away_count;
      }
    }
    foreach my $version (@versions){
      unless ($bdm_away{$version}){
        $bdm_away{$version} = 0;
      }
      unless ($bdm_home{$version}){
        $bdm_home{$version} = 0;
      }
    }
    print "\n$id\tbdm_count\thome\tstart\t$bdm_home{'burn'}";
    print "\n$id\tbdm_count\taway\tstart\t$bdm_away{'test'}";
    print "\n$id\tbdm_count\thome\tcontrol\t$bdm_home{'control'}";
    print "\n$id\tbdm_count\taway\tcontrol\t$bdm_away{'test'}";
    print "\n$id\tbdm_count\thome\ttest\t$bdm_home{'test'}";
    print "\n$id\tbdm_count\taway\ttest\t$bdm_away{'test'}";    
          
  }else{
    #Print nothing
  }
}
