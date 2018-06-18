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
#summary_df <- summary_df %>%
#  filter(phase != "burn_in")

# summarise the summaries (!)
# percent_diff = treatment (shift) - control (no shift)
# -ve value = treatment resulted in an increase in introgression (less RI)

sum_df <- summary_df  %>%
  group_by(ne, m, div_sel_n, div_sel_s, mu, delta, bdm_n, bdm_s, seed, rep) %>%
  summarise(p1_home_percent_diff = p1_home_percent[2] - p1_home_percent[3],
            p2_home_percent_diff = p2_home_percent[2] - p2_home_percent[3],
            fit_dif_diff = fit_dif[2] - fit_dif[3],
            pre_fit = fit_dif[1],
            test_post_fit =fit_dif[2],
            control_post_fit = fit_dif[3],
            pre_p1 = p1_home_percent[1],
            test_post_p1 = p1_home_percent[2],
            control_post_p1 = p1_home_percent[3])

# plot some results
summary_df %>%
  mutate(ne_m = ne*m) %>%
  filter(div_sel_s == 0.008, ne==1000, m==0.05) %>%
  ggplot(aes(y = p1_home_percent, x = as.factor(delta), color = as.factor(treatment)))+
  geom_boxplot()+
  facet_grid(ne*m ~ div_sel_s)


sum_df %>% filter(bdm_s == 0.001) %>% 
  #filter(div_sel_s == 0.008, ne==1000, m==0.1) %>%
  ggplot(aes(y = control_post_p1, x = test_post_p1, color = delta))+
  geom_point(alpha=0.5) +
  geom_abline(slope=1) +
  facet_grid(ne*m ~ div_sel_s, labeller = label_both) +
  theme_bw()

sum_df %>% filter(bdm_s == 0.001) %>% 
  filter(div_sel_s == 0.008, ne==1000, m==0.1) %>%
  filter(pre_fit > 0.4) %>%
  ggplot(aes(p1_home_percent_diff, fill = delta, group = delta))+
  geom_density() + facet_wrap(~delta, labeller = label_both) +
  theme_bw()
  
