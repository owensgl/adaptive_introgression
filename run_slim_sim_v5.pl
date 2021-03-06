#!/bin/perl
#This script is written to call slim scripts in parallel and record the output in an understandable format.
#This script version is for varying a single parameter at a time. 
use warnings;
use strict;
use Getopt::Long;
use Time::HiRes;
use Parallel::ForkManager;


#NOTE: This is the path to your nonWF slim program
my $slim = "/scratch/gowens/build/slim";
#my $slim = "/home/owens/working/SLiM/bin/slim";
#PARALLEL EXECUTION
my $pm = new Parallel::ForkManager(32);
my %p;
$p{"popsize"} = 1000; #Population size
$p{"m"} = 0.01; #Mutation rate
$p{"rimax"} = 1.5; #Total amount of reproductive isolation amongst all divergently selected sites and BDM pairs
$p{"totaldivbdmn"} = 100; #Number of divergently selected loci and BDM
$p{"proportionbdm"} = 0.0; #Proportion of loci that are BDM (from BDM + Divergent selected sites)
$p{"mutationrate"} = 1e-7; #Mutation rate for adaptive alleles
$p{"qtlsd"} = 1; #Standard deviation of qtl 
$p{"fitnesssd"} = 2.0; #Standard deviation of fitness landscape.
$p{"delta"} = 1; #How fast the optimum shifts after the burn in
my $reps =1;  #Number of repetitions per set of parameters
$p{"burningen"} = 10000; #Number of generations of burn in before shift
$p{"shiftgen"} = 100; #Number of generations of shifting optimum.
$p{"recombinationrate"} = 1e-5; #Number of generations of shifting optimum.
my $max_runs = 100; #Maximum number of replicates before it starts skipping.
my $output_dir = "output";

my @parameters = sort keys %p;
my %varying_p; #each parameter that is going to vary individually. 
my %starting_p; #The starting point for incrementing;
my %ending_p; #The ending point
my %increment_p; #The amount it increases with each increment
#PARAMETERS TO VARY
#$varying_p{"delta"}++;
#$varying_p{"qtlsd"}++;
#$varying_p{"mutationrate"}++;
#$varying_p{"rimax"}++;
#$varying_p{"m"}++;
#$varying_p{"totaldivbdmn"}++;
#$varying_p{"recombinationrate"}++;
$varying_p{"proportionbdm"}++;

#Starting point of parameters
$starting_p{"delta"}= 0.1;
$starting_p{"qtlsd"}= 0.1;
$starting_p{"mutationrate"} = 1e-8;
$starting_p{"rimax"} = 0.7;
$starting_p{"m"} = 0.0;
$starting_p{"totaldivbdmn"} = 5;
$starting_p{"recombinationrate"} = 1e-5;
$starting_p{"proportionbdm"} = 0.04;

#Ending point of parameters
$ending_p{"delta"}= 3;
$ending_p{"qtlsd"}= 5;
$ending_p{"mutationrate"} = 5e-7;
$ending_p{"rimax"} = 2;
$ending_p{"m"} = 0.1;
$ending_p{"totaldivbdmn"} = 15;
$ending_p{"recombinationrate"} = 5e-5;
$ending_p{"proportionbdm"} = 1.0;

#Increment for parameters
$increment_p{"delta"}= 0.05;
$increment_p{"qtlsd"}= 0.1;
$increment_p{"mutationrate"} = 1e-8;
$increment_p{"rimax"} = 0.05;
$increment_p{"m"} = 0.001;
$increment_p{"totaldivbdmn"} = 5;
$increment_p{"recombinationrate"} = 1e-6;
$increment_p{"proportionbdm"} = 0.04;


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
		if ($tmp_p{"m"} > 0.5){next;} #Skip if migration is greater than panmixis.
		foreach my $rep (1..$reps){
			$pm->start and next;
			srand();
			my $seed = int(rand(100000000000));
			my $varying_parameter_reformat = $varying_parameter;
			my $prefix = "output_$varying_parameter_reformat";
			my $filename = "$output_dir/output_$varying_parameter_reformat";
			foreach my $parameter (@parameters){
				$filename .= "_$tmp_p{$parameter}";
				$prefix .= "_$tmp_p{$parameter}";
			}
			my $run_count = `ls $output_dir | grep ${prefix}_ | grep out3.txt.gz | wc -l`;
			if ($run_count >= $max_runs){next;} #Skip runs where we already have enough replicates
			$filename .= "_${rep}_${seed}";
			my $filename_1 = $filename."_out1.txt";
			my $filename_2 = $filename."_out2.txt";
			my $filename_3 = $filename."_out3.txt";
			my $filename_6 = $filename."_out6.txt";
			open (my $fh1,'>', $filename_1);
			open (my $fh2,'>', $filename_2);
			open (my $fh3,'>', $filename_3);
			open (my $fh6,'>', $filename_6);
			print $fh1 "output\tversion\tgeneration\toptimum\tp1fit\tp1mean\tp1sd\tp2fit\tp2mean\tp2sd";
			print $fh2 "output\tversion\tp1home\tp2home\tp1_div_count\tp2_div_count";
			print $fh3 "output\tversion\tpop\tmut_position\tmut_subpopID\tmutFreq\tmut_selectionCoeff";
			print $fh6 "output\tversion\tpop\tbdm_pair\tstate\tbdm_id\tbdm_pos\tbdm_freq";
			print STDERR "Running burn in for $filename\n";
			my $command_1 = "$slim";
                        foreach my $parameter (@parameters){
				if ($parameter eq "proportionbdm"){
	                                $command_1 .= " -d d${parameter}=".sprintf("%.2f",$tmp_p{$parameter});
				}else{
					$command_1 .= " -d d${parameter}=$tmp_p{$parameter}";
				}
                        }
			$command_1 .= " -d drep=$rep";
			$command_1 .= " -d dseed=$seed";
			$command_1 .= ' -d dversion=\"burn\" adaptive_introgression_WF_BDM_CMD.slim';
			my $output_1 = `$command_1`;
#			my $output_1 = "NA";
#			print "$command_1\n";
			chomp($output_1);
                        my @lines = split(/\n/,$output_1);
                        foreach my $line (@lines){
				$line =~ s/^\s+//;
                                if ($line =~ m/^OUT1/){
					print $fh1 "\n$line";
				}elsif ($line =~ m/^OUT2/){
					print $fh2 "\n$line";
				}elsif ($line =~ m/^OUT3/){
					print $fh3 "\n$line";
				}elsif ($line =~ m/^OUT6/){
					print $fh6 "\n$line";
				}
			}
			print STDERR "Running test shift for $filename\n";
                        my $command_2 = "$slim";
                        foreach my $parameter (@parameters){
                                if ($parameter eq "proportionbdm"){
                                        $command_2 .= " -d d${parameter}=".sprintf("%.2f",$tmp_p{$parameter});
                                }else{
                                        $command_2 .= " -d d${parameter}=$tmp_p{$parameter}";
                                }
                        }
			$command_2 .= " -d drep=$rep";
                        $command_2 .= " -d dseed=$seed";
                        $command_2 .= ' -d dversion=\"test\" adaptive_introgression_WF_BDM_CMD.slim';
			my $output_2 = `$command_2`;
#			my $output_2 = "NA";
#			print "$command_2\n";
			chomp($output_2);
			@lines = split(/\n/,$output_2);
                        foreach my $line (@lines){
				$line =~ s/^\s+//;
                                if ($line =~ m/^OUT1/){
					print $fh1 "\n$line";
				}elsif ($line =~ m/^OUT2/){
					print $fh2 "\n$line";
				}elsif ($line =~ m/^OUT3/){
					print $fh3 "\n$line";
				}elsif ($line =~ m/^OUT6/){
                                        print $fh6 "\n$line";
                                }
			}
			my $longer_gen = $tmp_p{burningen} + $tmp_p{shiftgen};
			print STDERR "Running control for $filename\n";
                        my $command_3 = "$slim";
                        foreach my $parameter (@parameters){
				if ($parameter eq "burningen"){next;}
				if ($parameter eq "shiftgen"){next;}
                                if ($parameter eq "proportionbdm"){
                                        $command_3 .= " -d d${parameter}=".sprintf("%.2f",$tmp_p{$parameter});
                                }else{
                                        $command_3 .= " -d d${parameter}=$tmp_p{$parameter}";
                                }
                        }
			$command_3 .= " -d dshiftgen=0";
			$command_3 .= " -d dburningen=$longer_gen";
			$command_3 .= " -d drep=$rep";
                        $command_3 .= " -d dseed=$seed";
                        $command_3 .= ' -d dversion=\"control\" adaptive_introgression_WF_BDM_CMD.slim';
                        my $output_3 = `$command_3`;
#			my $output_3 = "NA";
#			print "$command_3\n";
			chomp($output_3);
			@lines = split(/\n/,$output_3);

			foreach my $line (@lines){
				$line =~ s/^\s+//;
                                if ($line =~ m/^OUT1/){
					print $fh1 "\n$line";
				}elsif ($line =~ m/^OUT2/){
					print $fh2 "\n$line";
				}elsif ($line =~ m/^OUT3/){
					print $fh3 "\n$line";
				}elsif ($line =~ m/^OUT6/){
                                        print $fh6 "\n$line";
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
