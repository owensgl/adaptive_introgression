# plot simulation output

library("tidyverse")


# read in simulation summaries
summary_df <- read.table("processed/sim_summary.txt.gz", h = T)

# spike in the bdm_n and bdm_s parameters
# param string: ne, m , burn_in_gen, div_n, div_s, bdm_n, bdm_s, mu, delta
summary_df <- summary_df %>%
  mutate(bdm_n = strsplit(as.character(param_string), split = "_") %>% unlist %>% .[6]) %>%
  mutate(bdm_s = strsplit(as.character(param_string), split = "_") %>% unlist %>% .[7]) 

# not interested in burn in phase
summary_df <- summary_df %>%
  filter(phase != "burn_in")

# summarise the summaries (!)
# percent_diff = treatment (shift) - control (no shift)
# -ve value = treatment resulted in an increase in introgression (less RI)

sum_df <- summary_df  %>%
  group_by(ne, m, div_sel_n, div_sel_s, mu, delta, bdm_n, bdm_s, seed, rep) %>%
  summarise(p1_home_percent_diff = p1_home_percent[1] - p1_home_percent[2],
            p2_home_percent_diff = p2_home_percent[1] - p2_home_percent[2],
            fit_dif_diff = fit_dif[1] - fit_dif[2])

# plot some results
summary_df %>%
  mutate(ne_m = ne*m) %>%
  ggplot(aes(y = p1_home_percent, x = as.factor(delta), color = as.factor(treatment)))+
  geom_boxplot()+
  facet_grid(ne_m ~ div_sel_s)


sum_df %>%
  ggplot(aes(y = p1_home_percent_diff, x = delta, fill = delta))+
  geom_boxplot()+
  facet_grid(ne*m ~ mu)