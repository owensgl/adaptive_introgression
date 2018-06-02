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
my $pm = new Parallel::ForkManager(1);

my @chosen_k = qw(100);
my @chosen_m = qw(0.1);
my @chosen_div_n = qw(100);
my @chosen_div_s = qw(0.008);
my @chosen_bdm_n = qw(10);
my @chosen_bdm_s = qw(0);
my @chosen_mutation_rate = qw(1e-7);
my @chosen_delta = qw(0.1);
my $reps =10; 
my $burn_in_gen = 3500;
my $shift_gen = 100;
foreach my $chosen_k (@chosen_k){
	foreach my $chosen_m (@chosen_m){
		foreach my $chosen_div_n (@chosen_div_n){
			foreach my $chosen_div_s (@chosen_div_s){
				foreach my $rep (1..$reps){
					foreach my $chosen_mutation_rate (@chosen_mutation_rate){
						foreach my $chosen_delta (@chosen_delta){
							foreach my $chosen_bdm_n (@chosen_bdm_n){
					                        foreach my $chosen_bdm_s (@chosen_bdm_s){
							
									$pm->start and next;
									srand();
									my $filename = "output_${chosen_k}_${chosen_m}_${burn_in_gen}_${chosen_div_n}_${chosen_div_s}_${chosen_bdm_n}_${chosen_bdm_s}_${chosen_mutation_rate}_${chosen_delta}_${rep}.txt";
									open (my $fh,'>', $filename);
									my $seed = int(rand(100000000000));
									my $output_1 = `$slim -d d_pop_size=$chosen_k -d d_m=$chosen_m -d d_div_sel_n=$chosen_div_n -d d_div_sel_s=$chosen_div_s -d d_bdm_s=$chosen_bdm_s -d d_bdm_n=$chosen_bdm_n -d d_mutation_rate=$chosen_mutation_rate -d d_delta=$chosen_delta -d d_rep=$rep -d d_seed=$seed -d d_burn_in_gen=$burn_in_gen -d d_shift_gen=$shift_gen adaptive_introgression_WF_BDM_BURNIN_CMD.slim`;
									chomp($output_1);
									my @lines = split(/\n/,$output_1);
									foreach my $line (@lines){
										if ($line =~ m/^OUT/){
											print $fh "$seed\ttest\t$line\n";
										}
									}
                                                                        my $output_2 = `$slim -d d_pop_size=$chosen_k -d d_m=$chosen_m -d d_div_sel_n=$chosen_div_n -d d_div_sel_s=$chosen_div_s -d d_bdm_s=$chosen_bdm_s -d d_bdm_n=$chosen_bdm_n -d d_mutation_rate=$chosen_mutation_rate -d d_delta=$chosen_delta -d d_rep=$rep -d d_seed=$seed -d d_burn_in_gen=$burn_in_gen -d d_shift_gen=$shift_gen adaptive_introgression_WF_BDM_TEST_CMD.slim`;
                                                                        chomp($output_2);
                                                                        @lines = split(/\n/,$output_2);
                                                                        foreach my $line (@lines){
                                                                                if ($line =~ m/^OUT/){
                                                                                        print $fh "$seed\ttest\t$line\n";
                                                                                }
                                                                        }
									my $longer_gen = $burn_in_gen + $shift_gen;
                                              		          	my $output_3 = `$slim -d d_pop_size=$chosen_k -d d_m=$chosen_m -d d_div_sel_n=$chosen_div_n -d d_div_sel_s=$chosen_div_s -d d_bdm_s=$chosen_bdm_s -d d_bdm_n=$chosen_bdm_n -d d_mutation_rate=$chosen_mutation_rate -d d_delta=$chosen_delta -d d_rep=$rep -d d_seed=$seed -d d_burn_in_gen=$longer_gen -d d_shift_gen=0 adaptive_introgression_WF_BDM_TEST_CMD.slim`;
                                                        		chomp($output_3);
		                                                        @lines = split(/\n/,$output_3);
                		                                        foreach my $line (@lines){
                                		                                if ($line =~ m/^OUT/){
											if ($line =~ m/burn_in/){next;}
                                                                		        print $fh "$seed\tcontrol\t$line\n";
		                                                                }
                		                                        }
									close $fh;
									$pm->finish
								}
							}
						}
					}
				}
			}
		}
	}
}

$pm->wait_all_children;
