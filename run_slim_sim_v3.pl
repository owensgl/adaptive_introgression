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

my @chosen_k = qw(500);
my @chosen_m = qw(0.01);
my @chosen_div_n = qw(100);
my @chosen_div_s = qw(0.003);
my @chosen_mutation_rate = qw(1e-7);
my @chosen_delta = qw(0.01);
my $reps =1; 

foreach my $chosen_k (@chosen_k){
	foreach my $chosen_m (@chosen_m){
		foreach my $chosen_div_n (@chosen_div_n){
			foreach my $chosen_div_s (@chosen_div_s){
				foreach my $rep (1..$reps){
					foreach my $chosen_mutation_rate (@chosen_mutation_rate){
						foreach my $chosen_delta (@chosen_delta){
							
							$pm->start and next;
							my $output = `$slim -d d_pop_size=$chosen_k -d d_m=$chosen_m -d d_div_sel_n=$chosen_div_n -d d_div_sel_s=$chosen_div_s -d d_mutation_rate=$chosen_mutation_rate -d d_delta=$chosen_delta -d d_rep=$rep adaptive_introgression_WF_BDM_CMD.slim`;
							chomp($output);
							my @lines = split(/\n/,$output);
							foreach my $line (@lines){
								if ($line =~ m/^OUT/){
									print("$line\n");
								}
							}
							$pm->finish
						}
					}
				}
			}
		}
	}
}

$pm->wait_all_children;
