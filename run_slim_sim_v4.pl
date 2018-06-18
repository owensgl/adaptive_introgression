#!/bin/perl
#This script is written to call slim scripts in parallel and record the output in an understandable format.
#This script version is for varying a single parameter at a time. 
use warnings;
use strict;
use Getopt::Long;
use Time::HiRes;
use Parallel::ForkManager;


#NOTE: This is the path to your nonWF slim program
my $slim = "/home/owens/working/SLiM/bin/slim";
#PARALLEL EXECUTION
my $pm = new Parallel::ForkManager(10);
my %p;
$p{k} = 1000;
$p{m} = 0.01;
$p{div_n} = 100;
$p{div_s} = 0.005;
$p{bdm_n} = 10;
$p{bdm_s} = 0.0;
$p{mutation_rate} = 1e-7;
$p{delta} = 0.1;
my $reps =10; 
$p{burn_in_gen} = 1000;
$p{shift_gen} = 100;


my @p_changes = qw(0.1 0.5 1 2 10); #Numbers to multiply the starting values by. 
my %varying_p; #each parameter that is going to vary individually. 
$varying_p{m}++;
#$varying_p{div_s}++;
#$varying_p{mutation_rate}++;
#$varying_p{delta}++;

foreach my $varying_parameter (sort keys %varying_p){
	foreach my $p_change (@p_changes){
		my %tmp_p = %p;
		$tmp_p{$varying_parameter} = $p{$varying_parameter} * $p_change; #Multiply the chosen parameter up or down.
		if (($tmp_p{div_s} * $tmp_p{div_n}) >= 1){next;} #Skip if fitness penalty is greater than 1.
		if ($tmp_p{m} > 0.5){next;} #Skip if migration is greater than panmixis.
		foreach my $rep (1..$reps){
			$pm->start and next;
			srand();
			my $filename = "output_$tmp_p{k}_$tmp_p{m}_$tmp_p{burn_in_gen}_$tmp_p{div_n}_$tmp_p{div_s}_$tmp_p{bdm_n}_$tmp_p{bdm_s}_$tmp_p{mutation_rate}_$tmp_p{delta}_${rep}.txt";
			open (my $fh,'>', $filename);
			my $seed = int(rand(100000000000));
			print STDERR "Running burn in for output_$tmp_p{k}_$tmp_p{m}_$tmp_p{burn_in_gen}_$tmp_p{div_n}_$tmp_p{div_s}_$tmp_p{bdm_n}_$tmp_p{bdm_s}_$tmp_p{mutation_rate}_$tmp_p{delta}_${rep}\n";
			my $output_1 = `$slim -d d_pop_size=$tmp_p{k} -d d_m=$tmp_p{m} -d d_div_sel_n=$tmp_p{div_n} -d d_div_sel_s=$tmp_p{div_s} -d d_bdm_s=$tmp_p{bdm_s} -d d_bdm_n=$tmp_p{bdm_n} -d d_mutation_rate=$tmp_p{mutation_rate} -d d_delta=$tmp_p{delta} -d d_rep=$rep -d d_seed=$seed -d d_burn_in_gen=$tmp_p{burn_in_gen} -d d_shift_gen=$tmp_p{shift_gen} -d_version="burn" adaptive_introgression_WF_BDM_CMD.v2.slim`;
			chomp($output_1);
                        my @lines = split(/\n/,$output_1);
                        foreach my $line (@lines){
                                if ($line =~ m/^OUT/){
					print $fh "$seed\ttest\t$line\n";
				}
			}
			print STDERR "Running test shift for output_$tmp_p{k}_$tmp_p{m}_$tmp_p{burn_in_gen}_$tmp_p{div_n}_$tmp_p{div_s}_$tmp_p{bdm_n}_$tmp_p{bdm_s}_$tmp_p{mutation_rate}_$tmp_p{delta}_${rep}\n";
			my $output_2 = `$slim -d d_pop_size=$tmp_p{k} -d d_m=$tmp_p{m} -d d_div_sel_n=$tmp_p{div_n} -d d_div_sel_s=$tmp_p{div_s} -d d_bdm_s=$tmp_p{bdm_s} -d d_bdm_n=$tmp_p{bdm_n} -d d_mutation_rate=$tmp_p{mutation_rate} -d d_delta=$tmp_p{delta} -d d_rep=$rep -d d_seed=$seed -d d_burn_in_gen=$tmp_p{burn_in_gen} -d d_shift_gen=$tmp_p{shift_gen} -d_version="test" adaptive_introgression_WF_BDM_CMD.v2.slim`;
			chomp($output_2);
			@lines = split(/\n/,$output_2);
			foreach my $line (@lines){
				if ($line =~ m/^OUT/){
					print $fh "$seed\ttest\t$line\n";
				}
			}
			my $longer_gen = $tmp_p{burn_in_gen} + $tmp_p{shift_gen};
			print STDERR "Running control for output_$tmp_p{k}_$tmp_p{m}_$tmp_p{burn_in_gen}_$tmp_p{div_n}_$tmp_p{div_s}_$tmp_p{bdm_n}_$tmp_p{bdm_s}_$tmp_p{mutation_rate}_$tmp_p{delta}_${rep}\n";
			my $output_3 = `$slim -d d_pop_size=$tmp_p{k} -d d_m=$tmp_p{m} -d d_div_sel_n=$tmp_p{div_n} -d d_div_sel_s=$tmp_p{div_s} -d d_bdm_s=$tmp_p{bdm_s} -d d_bdm_n=$tmp_p{bdm_n} -d d_mutation_rate=$tmp_p{mutation_rate} -d d_delta=$tmp_p{delta} -d d_rep=$rep -d d_seed=$seed -d d_burn_in_gen=$longer_gen -d d_shift_gen=0 -d_version="test" adaptive_introgression_WF_BDM_CMD.v2.slim`;
			chomp($output_3);
			@lines = split(/\n/,$output_3);
			foreach my $line (@lines){
				if ($line =~ m/^OUT/){
					if ($line =~ m/burn_in/){next;}
					print $fh "$seed\tcontrol\t$line\n";
				}
			}
			close $fh;
			system("rm states/slim_$seed.txt");
			system("gzip -f $filename");
			$pm->finish
		}
	}
}
$pm->wait_all_children;
