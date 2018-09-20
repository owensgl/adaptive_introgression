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
my $pm = new Parallel::ForkManager(11);
my %p;
$p{pop_size} = 1000; #Population size
$p{m} = 0.01; #Mutation rate
$p{total_div} = 0.9; #Total amount of reproductive isolation amongst all divergently selected sites.
$p{div_sel_n} = 100; #Number of divergently selected alleles
$p{div_sel_s} = $p{total_div}/$p{div_sel_n}; #Strength of selection at divergently selected alleles
$p{bdm_n} = 10; #Number of BDM alleles, must be divisible by 2
$p{bdm_s} = 0.0; #Strength of selection at BDMs
$p{mutation_rate} = 1e-7; #Mutation rate for adaptive alleles
$p{qtl_sd} = 1; #Standard deviation of qtl 
$p{fitness_sd} = 2.0; #Standard deviation of fitness landscape.
$p{delta} = 1; #How fast the optimum shifts after the burn in
my $reps =10;  #Number of repetitions per set of parameters
$p{burn_in_gen} = 10000; #Number of generations of burn in before shift
$p{shift_gen} = 100; #Number of generations of shifting optimum.

my @parameters = sort keys %p;
my %varying_p; #each parameter that is going to vary individually. 
my %starting_p; #The starting point for incrementing;
my %ending_p; #The ending point
my %increment_p; #The amount it increases with each increment
#PARAMETERS TO VARY
$varying_p{delta}++;
$varying_p{qtl_sd}++;
$varying_p{mutation_rate}++;
$varying_p{total_div}++;
$varying_p{m}++;

#Starting point of parameters
$starting_p{delta}= 0.1;
$starting_p{qtl_sd}= 0.1;
$starting_p{mutation_rate} = 1e-8;
$starting_p{total_div} = 0.1;
$starting_p{m} = 0.001;

#Ending point of parameters
$ending_p{delta}= 5;
$ending_p{qtl_sd}= 5;
$ending_p{mutation_rate} = 5e-7;
$ending_p{total_div} = 1;
$ending_p{m} = 0.1;

#Increment for parameters
$increment_p{delta}= 0.01;
$increment_p{qtl_sd}= 0.1;
$increment_p{mutation_rate} = 1e-8;
$increment_p{total_div} = 0.01;
$increment_p{m} = 0.001;





my $parameter_file = "parameter_file.txt";
open (my $ph, '>', $parameter_file);
foreach my $parameter (@parameters){
        print $ph "$parameter\t";

}
print $ph "rep\t";
print $ph "seed";
close $ph;

foreach my $varying_parameter (sort keys %varying_p){
	for (my $new_p = $starting_p{$varying_parameter}; $new_p <= $ending_p{$varying_parameter}; $new_p += $increment_p{$varying_parameter} ){ 
		my %tmp_p = %p;
		$tmp_p{$varying_parameter} = $new_p;
		if ($tmp_p{m} > 0.5){next;} #Skip if migration is greater than panmixis.
		$tmp_p{div_sel_s} = $tmp_p{total_div}/$tmp_p{div_sel_n};
		foreach my $rep (1..$reps){
			$pm->start and next;
			srand();
			my $seed = int(rand(100000000000));
			my $filename = "output_$varying_parameter";
			foreach my $parameter (@parameters){
				$filename .= "_$tmp_p{$parameter}";
			}
			$filename .= "_${rep}_${seed}";
			my $filename_1 = $filename."_out1.txt";
			my $filename_2 = $filename."_out2.txt";
			my $filename_3 = $filename."_out3.txt";
			open (my $fh1,'>', $filename_1);
			open (my $fh2,'>', $filename_2);
			open (my $fh3,'>', $filename_3);
			print $fh1 "output\tversion\tgeneration\toptimum\tp1fit\tp1mean\tp1sd\tp1logmean\tp1logsd\tp2fit\tp2mean\tp2sd\tp2logmean\tp2logsd";
			print $fh2 "output\tversion\tp1home\tp2home\tfit_dif";
			print $fh3 "output\tversion\tpop\tmut_position\tmut_subpopID\tmutFreq\tmut_selectionCoeff";
			print STDERR "Running burn in for $filename\n";
			my $command_1 = "$slim";
                        foreach my $parameter (@parameters){
                                $command_1 .= " -d d_${parameter}=$tmp_p{$parameter}";
                        }
			$command_1 .= " -d d_rep=$rep";
			$command_1 .= " -d d_seed=$seed";
			$command_1 .= ' -d d_version=\"burn\" adaptive_introgression_WF_BDM_CMD.slim';
			my $output_1 = `$command_1`;
			chomp($output_1);
                        my @lines = split(/\n/,$output_1);
                        foreach my $line (@lines){
                                if ($line =~ m/^OUT1/){
					print $fh1 "\n$line";
				}elsif ($line =~ m/^OUT2/){
					print $fh2 "\n$line";
				}elsif ($line =~ m/^OUT3/){
					print $fh3 "\n$line";
				}
			}
			print STDERR "Running test shift for $filename\n";
                        my $command_2 = "$slim";
                        foreach my $parameter (@parameters){
                                $command_2 .= " -d d_${parameter}=$tmp_p{$parameter}";
                        }
			$command_2 .= " -d d_rep=$rep";
                        $command_2 .= " -d d_seed=$seed";
                        $command_2 .= ' -d d_version=\"test\" adaptive_introgression_WF_BDM_CMD.slim';
			my $output_2 = `$command_2`;
			chomp($output_2);
			@lines = split(/\n/,$output_2);
                        foreach my $line (@lines){
                                if ($line =~ m/^OUT1/){
					print $fh1 "\n$line";
				}elsif ($line =~ m/^OUT2/){
					print $fh2 "\n$line";
				}elsif ($line =~ m/^OUT3/){
					print $fh3 "\n$line";
				}
			}
			my $longer_gen = $tmp_p{burn_in_gen} + $tmp_p{shift_gen};
			print STDERR "Running control for $filename\n";
                        my $command_3 = "$slim";
                        foreach my $parameter (@parameters){
				if ($parameter eq "burn_in_gen"){next;}
				if ($parameter eq "shift_gen"){next;}
                                $command_3 .= " -d d_${parameter}=$tmp_p{$parameter}";
                        }
			$command_3 .= " -d d_shift_gen=0";
			$command_3 .= " -d d_burn_in_gen=$longer_gen";
			$command_3 .= " -d d_rep=$rep";
                        $command_3 .= " -d d_seed=$seed";
                        $command_3 .= ' -d d_version=\"control\" adaptive_introgression_WF_BDM_CMD.slim';
                        my $output_3 = `$command_3`;
			chomp($output_3);
			@lines = split(/\n/,$output_3);

			foreach my $line (@lines){
                                if ($line =~ m/^OUT1/){
					print $fh1 "\n$line";
				}elsif ($line =~ m/^OUT2/){
					print $fh2 "\n$line";
				}elsif ($line =~ m/^OUT3/){
					print $fh3 "\n$line";
				}
			}
			close $fh1;
			close $fh2;
			close $fh3;
			system("rm states/slim_$seed.txt");
			system("gzip -f $filename*");
			$pm->finish
		}
	}
}
$pm->wait_all_children;
