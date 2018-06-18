#!/bin/perl
use strict;
use warnings;

my $d_version = "test";
my $d_pop_size = "1000";
my $d_m = "0.01";
my $d_div_sel_n = "100";
my $d_div_sel_s = "0.08";
my $d_bdm_n = "10";
my $d_bdm_s = "0.0";
my $d_mutation_rate="1e-7";
my $d_delta = "0.1";
my $d_seed = "1111";
my $d_burn_in_gen = "1000";
my $d_shift_gen = "100";
my $d_rep = "100";

my $input_file = $ARGV[0];
my $output_file = $ARGV[1];


system("cat $input_file | sed s/d_version/$d_version/g | sed s/d_pop_size/$d_pop_size/g | sed s/d_div_sel_n/$d_div_sel_n/g | sed s/d_div_sel_s/$d_div_sel_s/g | sed s/d_bdm_n/$d_bdm_n/g | sed s/d_bdm_s/$d_bdm_s/g | sed s/d_mutation_rate/$d_mutation_rate/g | sed s/d_delta/$d_delta/g | sed s/d_seed/$d_seed/g | sed s/d_burn_in_gen/$d_burn_in_gen/g | sed s/d_shift_gen/$d_shift_gen/g | sed s/d_m/$d_m/g | sed s/d_rep/$d_rep/g > $output_file ");
