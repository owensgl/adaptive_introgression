#!/bin/perl
#This script is written to call slim scripts in parallel and record the output in an understandable format.
#It accepts output using -- to flag parameters. For example --k 400 to change the population size to 400. 
#It writes a new slim file substituting the parameters into the script. It looks for # flag to find parameters to substitute. 
#It runs slim, then harvests the output into 3 files, the parameters used, the summary output, and the m3 mutations. Everything is kept consistent by the timestamp, which should be unique (and would be a problem if it wasn't). 
use warnings;
use strict;
use Getopt::Long;
use Time::HiRes;

#NOTE: This is the path to your nonWF slim program
my $slim = "/Applications/nonWF_slim/slim";
my $k = 500; #The population size carrying capacity
my $m = 0.01; #The migration rate
my $ri_n = "10"; #The number of RI loci
my $ri_architecture = "diffuse"; #Whether RI loci are clustered or diffuse
my $ri_max = "0.5"; #Total RI strength
my $delta = "0.05"; #Change in optimal phenotype per generation
my $mutation_rate = "1.5e-8"; #Mutation rate
my $total_generations = "5000"; #Total generations to run for
my $template = "adaptive_introgression_vG1_template.slim"; #The template slim script to be modified and run.
my $remove_template = "T"; #Whether to remove the template T or F.
GetOptions (
        "k=i" => \$k,
        "m=f"   => \$m,
        "ri_n=i"  => \$ri_n,
        "ri_architecture=s" => \$ri_architecture,
        "ri_max=f" => \$ri_max,
        "delta=f" => \$delta,
        "mutation_rate=s" => \$mutation_rate,
	"template=s" => \$template,
	"total_generations=i" => \$total_generations
                );

my $timestamp = Time::HiRes::time();
#my $timestamp = "TMP";
my $template_header= $template;
$template_header =~ s/.slim//g;
print STDERR "TIMESTAMP: $timestamp\n";

#Make a folder for the parameter set
my $folder = "slim_${k}_${m}_${ri_n}_${ri_architecture}_${ri_max}_${delta}_${mutation_rate}_${total_generations}";
mkdir $folder unless -d $folder;

my $template_out = "$folder/$template_header.$timestamp.slim";

system("cat $template | sed s/#k/$k/g  | sed s/#mig/$m/g | sed s/#ri_n/$ri_n/g | sed s/#ri_architecture/$ri_architecture/g | sed s/#ri_max/$ri_max/g | sed s/#delta/$delta/g | sed s/#mutation_rate/$mutation_rate/g | sed s/#generations/$total_generations/g > $template_out");


#Open outfiles
my $parameter_out = "$folder/parameters.$timestamp.txt";
my $summary_out = "$folder/summary.$timestamp.txt";
my $mutations_out = "$folder/mutations.$timestamp.txt";

open (my $par_out, '>', $parameter_out);
open (my $sum_out, '>', $summary_out);
open (my $mut_out, '>', $mutations_out);

#Print out parameter file
print $par_out "timestamp\tk\tm\tri_n\tri_architecture\tri_max\tdelta\tmutation_rate";
print $par_out "\n$timestamp\t$k\t$m\t$ri_n\t$ri_architecture\t$ri_max\t$delta\t$mutation_rate";

#prepare other outfiles
print $sum_out "timestamp\toutcome\tgenerations\tp1_n\tp2_n\tp1_ri\tp2_ri";
print $mut_out "timestamp\tpop\tloci\tstrength\tpop_origin\tstarting_gen";

#Run slim script and harvest output into simulation_summary and mutation_output.

my $result;
my $generations;
my $p1_n;
my $p2_n;
my $p1_ri;
my $p2_ri;
my $current_pop;
my $current_pop_size;
my @output = `$slim $template_out`;
chomp (@output);

foreach my $line(@output){
	unless($line){next;}
	if ($line =~ m/Complete/){
		$result = "Complete";
		my @tmp = split(/ /,$line);
		my @ris = split(/:/,$tmp[1]);
		$p1_ri = $ris[0];
		$p2_ri = $ris[1];
		$generations = $tmp[0];
		$generations =~ s/Complete://g;
	}elsif($line =~ "Extinction"){
	  	$result = "Extinction";
		my @tmp = split(/ /,$line);
		my @ris = split(/:/,$tmp[1]);
                $p1_ri = $ris[0];
                $p2_ri = $ris[1];
		$generations = $tmp[0];
                $generations =~ s/Extinction://g;
		if ($p1_ri eq "NA"){
			$p1_n = "0";
		}elsif($p2_ri eq "NA"){
			$p2_n = "0";
		}
	}
	if ($line =~ m/^#OUT/){
		my @tmp = split(/ /,$line);
		$current_pop = $tmp[3];
		if ($current_pop eq "p1"){
			$p1_n = $tmp[4];
		}elsif ($current_pop eq "p2"){
			$p2_n = $tmp[4];
		}
		$current_pop_size = $tmp[4];
	}
	if ($line =~ / m3 /){
		my @tmp = split(/ /,$line);
		my $location = $tmp[3];
		my $strength = $tmp[4];
		my $pop = $tmp[6];
		my $starting_gen = $tmp[7];
		my $final_count = $tmp[8];
		my $final_freq = $final_count / $current_pop_size;
		if ($final_freq < 0.5){next;}
		print $mut_out "\n$timestamp\t$current_pop\t$location\t$strength\t$pop\t$starting_gen";
	}
	
}
print $sum_out "\n$timestamp\t$result\t$generations\t$p1_n\t$p2_n\t$p1_ri\t$p2_ri";

if ($remove_template =~ /T/){
	system("rm $template_out");
}
