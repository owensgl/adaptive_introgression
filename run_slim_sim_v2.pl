#!/bin/perl
#This script is written to call slim scripts in parallel and record the output in an understandable format.
#This script 
use warnings;
use strict;
use Getopt::Long;
use Time::HiRes;
use Parallel::ForkManager;


#NOTE: This is the path to your nonWF slim program
my $slim = "/home/owens/working/SLiM/bin/slim";
#PARALLEL EXECUTION
my $pm = new Parallel::ForkManager(11);

my @chosen_k = qw(500 1000 2000 5000 10000);
my @chosen_m = qw(0.01);
my @chosen_div_n = qw(100);
my @chosen_div_s = qw(0.002 0.003 0.004);
my $reps =5; 

foreach my $chosen_k (@chosen_k){
	foreach my $chosen_m (@chosen_m){
		foreach my $chosen_div_n (@chosen_div_n){
			foreach my $chosen_div_s (@chosen_div_s){
				foreach my $rep (1..$reps){
					$pm->start and next;
					my $output = `$slim -d d_pop_size=$chosen_k -d d_m=$chosen_m -d d_div_sel_n=$chosen_div_n -d d_div_sel_s=$chosen_div_s adaptive_introgression_WF_BDM_CMD.slim | tail -n 1`;
					chomp($output);
					print("$output\n");
					$pm->finish
				}
			}
		}
	}
}

$pm->wait_all_children;
