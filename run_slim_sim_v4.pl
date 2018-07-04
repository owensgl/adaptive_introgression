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
my @p_changes = qw(10 5 2 1.5 1 0.75 0.5 0.2 0.1); #Numbers to multiply the starting values by.
#my @p_changes = qw(0.1 0.2 0.5 0.75 1 1.5 2 5 10); #Numbers to multiply the starting values by. 
my %varying_p; #each parameter that is going to vary individually. 

#PARAMETERS TO VARY
$varying_p{delta}++;
$varying_p{qtl_sd}++;
$varying_p{mutation_rate}++;
$varying_p{div_sel_n}++;
$varying_p{fitness_sd}++;

my $parameter_file = "parameter_file.txt";
open (my $ph, '>', $parameter_file);
foreach my $parameter (@parameters){
        print $ph "$parameter\t";

}
print $ph "rep";
close $ph;

foreach my $varying_parameter (sort keys %varying_p){
	foreach my $p_change (@p_changes){
		my %tmp_p = %p;
		$tmp_p{$varying_parameter} = $p{$varying_parameter} * $p_change; #Multiply the chosen parameter up or down.
		if ($tmp_p{m} > 0.5){next;} #Skip if migration is greater than panmixis.
		$tmp_p{div_sel_s} = $tmp_p{total_div}/$tmp_p{div_sel_n};
		foreach my $rep (1..$reps){
			$pm->start and next;
			srand();
			my $filename = "output";
			foreach my $parameter (@parameters){
				$filename .= "_$tmp_p{$parameter}";
			}
			$filename .= "_${rep}.txt";
			open (my $fh,'>', $filename);
			my $seed = int(rand(100000000000));
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
                                if ($line =~ m/^OUT/){
					print $fh "$seed\ttest\t$line\n";
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
				if ($line =~ m/^OUT/){
					print $fh "$seed\ttest\t$line\n";
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
			$command_3 .= " -d d_rep=$rep";
			$command_3 .= " -d d_burn_in_gen=$longer_gen";
                        $command_3 .= " -d d_seed=$seed";
                        $command_3 .= ' -d d_version=\"test\" adaptive_introgression_WF_BDM_CMD.slim';
                        my $output_3 = `$command_3`;
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
