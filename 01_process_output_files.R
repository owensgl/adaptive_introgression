# process simulation output
# aggregates + compresses replicates
# plots

library("tidyverse")
library("parallel")

# location of output files (folder)
out_folder <- "output/"

# locate the folder of output files
out_files <- list.files(out_folder)

# parse the output file names into a data frame
# "output_chosen_k_chosen_m_burn_in_gen_chosen_div_n_chosen_div_s_chosen_bdm_n_chosen_bdm_s_chosen_mutation_rate_$chosen_delta_rep.txt"

parse_output_filenames <- function(file_name){
  
  x <- strsplit(file_name, "_") %>% data.frame %>% t %>% data.frame
  names(x) <- c("slug","ne", "m", "burn_in_gen", "div_n", "div_s", "bdm_n", "bdm_s", "mu", "delta", "rep")
  x$rep <- gsub(".txt", "", x$rep)
  row.names(x) <- NULL
  x <- x[,c(2:11)]
  data.frame(x, file_name)
  
}


# create unique parameter strings for each param set
out_df <- lapply(out_files, parse_output_filenames)
out_df <- bind_rows(out_df)
out_df <- out_df %>%
  mutate(param_string = paste(ne, m , burn_in_gen, div_n, div_s, bdm_n, bdm_s, mu, delta, sep  = "_"))

# a list of all unique param strings
unique_param_strings <- unique(out_df$param_string)

# a robust function for parsing the outout of our slim simulations
# handles errors when necessary

safe_read_sim_output <- function(x){

  # grep the out1 and read as data frame
  # TBD: out2

  call_string <- paste0("grep OUT1 ", x)
  out1_df <- system(call_string, intern = TRUE) %>% strsplit(split = "\t") %>% 
    data.frame %>% t %>% data.frame
  
  # prevent processing of incomplete sim
  if(length(out1_df) == 15){
    
    row.names(out1_df) <- NULL
    names(out1_df) <- c("seed", "treatment", "out_type", "phase", "ne", "m", 
                        "burn_in_gens", "div_sel_n", "div_sel_s", "mu", "delta",
                        "p1_home_percent", "p2_home_percent", "fit_dif", "rep") 
    
    out1_df
    
  }
  
  
}

# function for aggregating multiple reps into single file per param set

summarise_simulation_output <- function(current_param_string){
  
  # subset of out files that match the query parameter string
  param_df <- out_df %>%
    filter(param_string == current_param_string)
  
  # join the files into a single data frame
  file_names <- paste0(out_folder, param_df$file_name)
  
  # read in sim files, silently ignoring incomplete runs
  sim_df <- lapply(file_names, safe_read_sim_output)
  sim_df <- bind_rows(sim_df)
  sim_df$param_string <- current_param_string
  sim_df
  
  
}

# apply the function over all sets
sim_summary <- lapply(unique_param_strings, summarise_simulation_output)
#sim_summary <- mclapply(unique_param_strings, summarise_simulation_output, mc.cores = 20)
sim_summary <- bind_rows(sim_summary)

write.table(sim_summary, file = gzfile("processed/sim_summary.txt.gz"), row.names = FALSE, quote = FALSE)

